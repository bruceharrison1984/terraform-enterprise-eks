# Terraform Enterprise EKS Example

This repo is an amalagation of:

- <https://github.com/hashicorp/terraform-aws-terraform-enterprise/tree/main>
- <https://github.com/hashicorp/learn-terraform-provision-eks-cluster>

This is a fast-ish way to get Terraform Enterprise up and running in EKS for troubleshooting.

## Outputs

_Outputs will be used to configure the TFE FDO Helm charts._

After running `terraform apply` the outputs should resemble the following:

```sh
cluster_endpoint = "https://C564F705E81B02BC904D37BEEC40B63B.gr7.us-east-1.eks.amazonaws.com"
cluster_name = "tfe-eks-NCajJ9Nj"
cluster_security_group_id = "sg-06069950c27b54382"
object_store_hostname = "tfe-tfe-data.s3.us-east-1.amazonaws.com"
postgres_password = <sensitive>
postgres_username = "hashicorp"
postsgres_endpoint = "tfe-tfe20240702194900779000000001.cp0pum8d5fu1.us-east-1.rds.amazonaws.com:5432"
redis_hostname = "tfe-tfe.h8g6tm.ng.0001.use1.cache.amazonaws.com"
region = "us-east-1"
```

You can retrieve the Postgres password explicitly with `terraform output postgres_password`.

## Kubectl Configuration

[Taken from Hashicorp EKS Tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks#configure-kubectl)

Run the following command to retrieve the access credentials for your cluster and configure kubectl.

```
aws eks --region $(terraform output \
        -raw region) update-kubeconfig \
        --name $(terraform output -raw cluster_name)
```

## TFE Helm Charts

See the offical [TFE Helm Charts repository](https://github.com/hashicorp/terraform-enterprise-helm) to get the charts to install TFE.

## misc

## Push TFE image pull secret to EKS

```sh
kubectl create namespace terraform-enterprise
kubectl create secret docker-registry terraform-enterprise --docker-server=images.releases.hashicorp.com --docker-username=terraform --docker-password=$(cat ./terraform.hclic)  -n terraform-enterprise
```

## Watch raw TFE logs as container comes up

```sh
while true; do sleep 1; kubectl exec -n terraform-enterprise -ti $(kubectl get pods -n terraform-enterprise | tail -1 | awk '{print $1}') -- tail -n 100 -f /var/log/terraform-enterprise/terraform-enterprise.log; done
```

- Upon deletion, EKS may not cleanup up ALBs that were created. These need to be manually removed before the VPC can be fully destroyed.
