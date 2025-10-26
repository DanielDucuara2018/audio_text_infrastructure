# Cloud Run Service URLs
output "api_url" {
  description = "Cloud Run API service URL"
  value       = google_cloud_run_service.api.status[0].url
}

output "worker_url" {
  description = "Cloud Run Worker service URL (internal only)"
  value       = google_cloud_run_service.worker.status[0].url
}

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

# Optional audio bucket
output "audio_bucket_name" {
  description = "Audio files bucket name (if created)"
  value       = var.create_audio_bucket ? google_storage_bucket.audio_files[0].name : "Using AWS S3"
}

# Cloudflare Configuration Instructions
output "cloudflare_dns_records" {
  description = "DNS records to configure in Cloudflare"
  value = {
    frontend = {
      type  = "CNAME"
      name  = var.frontend_subdomain
      value = google_storage_bucket.frontend.name
      note  = "Enable orange cloud (proxied) for CDN and SSL"
    }
    api = {
      type  = "CNAME"
      name  = var.api_subdomain
      value = trimsuffix(trimprefix(google_cloud_run_service.api.status[0].url, "https://"), "")
      note  = "Enable orange cloud (proxied) for DDoS protection and SSL"
    }
  }
}
