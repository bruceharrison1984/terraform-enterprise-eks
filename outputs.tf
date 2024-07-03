# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

# TFE PREREQS
#------------
output "postgres_password" {
  value       = module.tfe_prereqs.postgres_password
  description = "The password of the main PostgreSQL user."
  sensitive   = true
}

output "postgres_username" {
  value       = module.tfe_prereqs.postgres_username
  description = "The name of the main PostgreSQL user."
}

output "postsgres_endpoint" {
  value       = module.tfe_prereqs.postsgres_endpoint
  description = "The connection endpoint of the PostgreSQL RDS instance in address:port format."
}

output "redis_hostname" {
  value       = module.tfe_prereqs.redis_hostname
  description = "The IP address of the primary node in the Redis Elasticache replication group."
}

output "object_store_hostname" {
  value       = module.tfe_prereqs.object_store_hostname
  description = "The S3 bucket which contains TFE runtime data."
}

output "eks_iam_role_arn" {
  value = aws_iam_role.eks_service_principal.arn
}
