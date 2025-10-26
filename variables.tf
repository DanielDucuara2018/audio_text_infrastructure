# Project Configuration
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west4"
}

variable "credentials_file" {
  description = "Path to GCP service account credentials JSON file"
  type        = string
  default     = "credentials/gcp-key.json"
}

# Domain Configuration
variable "frontend_subdomain" {
  description = "Frontend subdomain (e.g., voiceia.techlab.com)"
  type        = string
}

variable "api_subdomain" {
  description = "API subdomain (e.g., api.voiceia.techlab.com)"
  type        = string
}

# Database Configuration
variable "db_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "audiotext"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "app_user"
}

# Redis Configuration
variable "redis_memory_gb" {
  description = "Redis memory size in GB"
  type        = number
  default     = 1
}

# Cloud Storage Configuration (Optional)
variable "create_audio_bucket" {
  description = "Create GCP bucket for audio files (set to false if using AWS S3)"
  type        = bool
  default     = false
}

variable "audio_bucket_name" {
  description = "Name for audio files bucket (if using GCP storage)"
  type        = string
  default     = ""
}

# Cloud Run Configuration
variable "api_min_instances" {
  description = "Minimum instances for API service"
  type        = number
  default     = 0
}

variable "api_max_instances" {
  description = "Maximum instances for API service"
  type        = number
  default     = 10
}

variable "api_memory" {
  description = "Memory allocation for API service"
  type        = string
  default     = "1Gi"
}

variable "api_cpu" {
  description = "CPU allocation for API service"
  type        = string
  default     = "1"
}

variable "worker_min_instances" {
  description = "Minimum instances for Worker service"
  type        = number
  default     = 1
}

variable "worker_max_instances" {
  description = "Maximum instances for Worker service"
  type        = number
  default     = 5
}

variable "worker_memory" {
  description = "Memory allocation for Worker service"
  type        = string
  default     = "4Gi"
}

variable "worker_cpu" {
  description = "CPU allocation for Worker service"
  type        = string
  default     = "2"
}

# Rate Limiting Configuration
variable "rate_limit_per_minute" {
  description = "Maximum requests per minute per IP"
  type        = number
  default     = 60
}

variable "rate_limit_per_hour" {
  description = "Maximum requests per hour per IP"
  type        = number
  default     = 1000
}
