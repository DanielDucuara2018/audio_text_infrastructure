# NOTE: Cloud Run services are managed by deploy-cloud.sh script
# These outputs provide the infrastructure details needed by the deployment script

# Frontend bucket
output "frontend_bucket_name" {
  description = "Frontend static files bucket name"
  value       = google_storage_bucket.frontend.name
}

output "frontend_bucket_url" {
  description = "Frontend bucket URL for Cloudflare CNAME"
  value       = "c.storage.googleapis.com"
}

# Database
output "database_private_ip" {
  description = "Cloud SQL private IP address"
  value       = google_sql_database_instance.main.private_ip_address
  sensitive   = true
}

output "database_name" {
  description = "Database name"
  value       = var.db_name
}

output "database_user" {
  description = "Database user"
  value       = var.db_user
}

output "database_connection_name" {
  description = "Cloud SQL connection name"
  value       = google_sql_database_instance.main.connection_name
}

output "database_password" {
  description = "Database password"
  value       = random_password.db_password.result
  sensitive   = true
}

# Redis
output "redis_host" {
  description = "Redis instance host"
  value       = google_redis_instance.main.host
}

output "redis_port" {
  description = "Redis instance port"
  value       = google_redis_instance.main.port
}

# VPC Connector
output "vpc_connector_name" {
  description = "VPC Access Connector name for Cloud Run services"
  value       = google_vpc_access_connector.main.name
}

# Storage
output "audio_bucket_name" {
  description = "Audio files bucket name (if created)"
  value       = var.create_audio_bucket ? google_storage_bucket.audio_files[0].name : "Using AWS S3"
}

# Deployment Configuration (for deploy-cloud.sh)
output "deployment_config" {
  description = "Complete deployment configuration for deploy-cloud.sh"
  value = jsonencode({
    db_host              = google_sql_database_instance.main.private_ip_address
    db_name              = var.db_name
    db_user              = var.db_user
    db_port              = "5432"
    redis_host           = google_redis_instance.main.host
    redis_port           = tostring(google_redis_instance.main.port)
    bucket_name          = var.create_audio_bucket ? google_storage_bucket.audio_files[0].name : var.audio_bucket_name
    region               = var.region
    vpc_connector        = google_vpc_access_connector.main.name
    cors_origins         = "https://${var.frontend_subdomain}"
    api_cpu              = var.api_cpu
    api_memory           = var.api_memory
    api_min_instances    = tostring(var.api_min_instances)
    api_max_instances    = tostring(var.api_max_instances)
    worker_cpu           = var.worker_cpu
    worker_memory        = var.worker_memory
    worker_min_instances = tostring(var.worker_min_instances)
    worker_max_instances = tostring(var.worker_max_instances)
  })
  sensitive = true
}
