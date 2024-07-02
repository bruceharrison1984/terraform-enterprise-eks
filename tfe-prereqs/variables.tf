# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "network_id" {
  type        = string
  description = "The identity of the VPC in which the security group attached to the Redis Elasticache replication group will be deployed."
}

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDR ranges to create in VPC."
}

variable "network_subnets_private" {
  type        = list(string)
  description = "A list of the identities of the private subnetworks in which the Redis Elasticache replication group will be deployed."
}

variable "kms_key_arn" {
  type        = string
  description = "The Amazon Resource Name of the KMS key which will be used by the Redis Elasticache replication group to encrypt data at rest."
}

variable "cluster_security_group_id" {
  type        = string
  description = "The security group ID associated with the EKS cluster."
}

# Postgres
# --------
variable "db_name" {
  default     = "hashicorp"
  type        = string
  description = "PostgreSQL instance name."
}

variable "db_username" {
  default     = "hashicorp"
  type        = string
  description = "PostgreSQL instance username. No special characters."
}

variable "db_backup_retention" {
  type        = number
  description = "The days to retain backups for. Must be between 0 and 35"
  default     = 0
}

variable "db_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  default     = null
}

variable "db_parameters" {
  type        = string
  description = "PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection."
  default     = "sslmode=require"
}

variable "db_size" {
  type        = string
  default     = "db.m5.xlarge"
  description = "PostgreSQL instance size."
}

variable "postgres_engine_version" {
  type        = string
  default     = "12.15"
  description = "PostgreSQL version."
}

# Redis
# -----
variable "redis_cache_size" {
  type        = string
  default     = "cache.m4.large"
  description = "Redis instance size."
}

variable "redis_encryption_in_transit" {
  type        = bool
  description = "Determine whether Redis traffic is encrypted in transit."
  default     = false
}

variable "redis_encryption_at_rest" {
  type        = bool
  description = "Determine whether Redis data is encrypted at rest."
  default     = false
}

variable "redis_engine_version" {
  type        = string
  default     = "7.0"
  description = "Redis engine version."
}

variable "redis_parameter_group_name" {
  type        = string
  default     = "default.redis7"
  description = "Redis parameter group name."
}

variable "redis_use_password_auth" {
  type        = bool
  description = "Determine if a password is required for Redis."
  default     = false
}

# S3
# -----
variable "s3_iam_principal_arn" {
  type        = string
  description = "ARN of an IAM principal who will access S3 object storage"
}
