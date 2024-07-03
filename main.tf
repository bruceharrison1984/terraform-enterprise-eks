# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      product = "tfe-eks"
    }
  }
}

# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = "tfe-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "tfe-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

/** this allows EKS to assume this role to interact with AWS */
data "aws_iam_policy_document" "trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:demo-s3:demo-sa"]
    }
  }
}

resource "aws_iam_role" "eks_service_principal" {
  name               = "eks-service-principal"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

module "tfe_prereqs" {
  source = "./tfe-prereqs"

  network_id                   = module.vpc.vpc_id
  network_private_subnet_cidrs = module.vpc.private_subnets_cidr_blocks
  network_subnets_private      = module.vpc.private_subnets
  friendly_name_prefix         = "eks"
  kms_key_arn                  = module.eks.kms_key_arn
  cluster_security_group_id    = module.eks.node_security_group_id ## is this right?
  s3_iam_principal_arn         = aws_iam_role.eks_service_principal.arn
}

resource "local_file" "helm_override" {
  content = templatefile(path, {
    TFE_DATABASE_HOST            = module.tfe_prereqs.postsgres_endpoint
    TFE_DATABASE_USER            = module.tfe_prereqs.postgres_username
    TFE_DATABASE_PASSWORD        = module.tfe_prereqs.postgres_password
    TFE_OBJECT_STORAGE_S3_BUCKET = module.tfe_prereqs.name
    TFE_OBJECT_STORAGE_S3_REGION = var.region
    TFE_SERVICE_ACCOUNT_ROLE_ARN = aws_iam_role.eks_service_principal.arn
    TFE_REDIS_HOST               = module.tfe_prereqs.redis_hostname
  })
  filename = "${path.module}/override.yaml"
}
