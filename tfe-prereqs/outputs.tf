output "postgres_password" {
  value       = module.database.password
  description = "The password of the main PostgreSQL user."
  sensitive   = false
}

output "postgres_username" {
  value       = module.database.username
  description = "The name of the main PostgreSQL user."
}

output "postsgres_endpoint" {
  value       = module.database.endpoint
  description = "The connection endpoint of the PostgreSQL RDS instance in address:port format."
}

output "redis_hostname" {
  value       = module.redis.hostname
  description = "The IP address of the primary node in the Redis Elasticache replication group."
}

output "object_store_name" {
  value       = module.object_storage.s3_bucket.bucket
  description = "The S3 bucket which contains TFE runtime data."
}

output "object_store_arn" {
  value       = module.object_storage.s3_bucket.arn
  description = "The ARN S3 bucket which contains TFE runtime data."
}

