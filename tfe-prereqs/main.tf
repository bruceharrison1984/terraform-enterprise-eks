
# -----------------------------------------------------------------------------
# AWS PostreSQL Database
# -----------------------------------------------------------------------------
module "database" {
  source = "./modules/database"

  db_size                      = var.db_size
  db_backup_retention          = var.db_backup_retention
  db_backup_window             = var.db_backup_window
  db_name                      = var.db_name
  db_parameters                = var.db_parameters
  db_username                  = var.db_username
  engine_version               = var.postgres_engine_version
  friendly_name_prefix         = var.friendly_name_prefix
  network_id                   = var.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_subnets_private      = var.network_subnets_private
  tfe_instance_sg              = var.cluster_security_group_id
  kms_key_arn                  = var.kms_key_arn
}

# -----------------------------------------------------------------------------
# AWS Redis - Elasticache Replication Group
# -----------------------------------------------------------------------------
module "redis" {
  source = "./modules/redis"

  active_active                = true
  friendly_name_prefix         = var.friendly_name_prefix
  network_id                   = var.network_id
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_subnets_private      = var.network_subnets_private
  tfe_instance_sg              = var.cluster_security_group_id

  cache_size           = var.redis_cache_size
  engine_version       = var.redis_engine_version
  parameter_group_name = var.redis_parameter_group_name

  kms_key_arn                 = var.kms_key_arn
  redis_encryption_in_transit = var.redis_encryption_in_transit
  redis_encryption_at_rest    = var.redis_encryption_at_rest
  redis_use_password_auth     = var.redis_use_password_auth
  redis_port                  = var.redis_encryption_in_transit ? "6380" : "6379"
}

# -----------------------------------------------------------------------------
# AWS S3 Bucket Object Storage
# -----------------------------------------------------------------------------
module "object_storage" {
  source = "./modules/object_storage"

  friendly_name_prefix = var.friendly_name_prefix
  iam_principal        = { arn = var.s3_iam_principal_arn }
  kms_key_arn          = var.kms_key_arn
}
