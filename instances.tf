# API Service (Cloud Run)
resource "google_cloud_run_service" "api" {
  name     = "audio-api"
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = var.api_min_instances
        "autoscaling.knative.dev/maxScale"        = var.api_max_instances
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.main.name
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        # Security: Only allow traffic from Cloudflare IPs
        "run.googleapis.com/ingress" = "all"
      }
    }

    spec {
      containers {
        image = "gcr.io/${var.project_id}/audio-api:latest"

        ports {
          container_port = 3203
        }

        resources {
          limits = {
            cpu    = var.api_cpu
            memory = var.api_memory
          }
        }

        # Infrastructure-tied environment variables (from Terraform)
        env {
          name  = "AUDIO_TEXT_DB_HOST_ENV"
          value = google_sql_database_instance.main.private_ip_address
        }

        env {
          name  = "AUDIO_TEXT_DB_NAME_ENV"
          value = var.db_name
        }

        env {
          name  = "AUDIO_TEXT_DB_USER_ENV"
          value = var.db_user
        }

        env {
          name  = "AUDIO_TEXT_DB_PASSWORD_ENV"
          value = random_password.db_password.result
        }

        env {
          name  = "AUDIO_TEXT_DB_PORT_ENV"
          value = "5432"
        }

        env {
          name  = "AUDIO_TEXT_REDIS_HOST_ENV"
          value = google_redis_instance.main.host
        }

        env {
          name  = "AUDIO_TEXT_REDIS_PORT_ENV"
          value = google_redis_instance.main.port
        }

        env {
          name  = "AUDIO_TEXT_AWS_BUCKET_NAME_ENV"
          value = var.create_audio_bucket ? google_storage_bucket.audio_files[0].name : var.audio_bucket_name
        }

        env {
          name  = "AUDIO_TEXT_AWS_REGION_ENV"
          value = var.region
        }

        env {
          name  = "AUDIO_TEXT_CORS_ORIGINS_ENV"
          value = "https://${var.frontend_subdomain}"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Allow unauthenticated access to API
resource "google_cloud_run_service_iam_member" "api_public" {
  service  = google_cloud_run_service.api.name
  location = google_cloud_run_service.api.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Worker Service (Cloud Run)
resource "google_cloud_run_service" "worker" {
  name     = "audio-worker"
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = var.worker_min_instances
        "autoscaling.knative.dev/maxScale"        = var.worker_max_instances
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.main.name
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "run.googleapis.com/cpu-throttling"       = "false"
      }
    }

    spec {
      containers {
        image = "gcr.io/${var.project_id}/audio-worker:latest"

        ports {
          container_port = 3203
        }

        resources {
          limits = {
            cpu    = var.worker_cpu
            memory = var.worker_memory
          }
        }

        # Infrastructure-tied environment variables (from Terraform)
        env {
          name  = "AUDIO_TEXT_DB_HOST_ENV"
          value = google_sql_database_instance.main.private_ip_address
        }

        env {
          name  = "AUDIO_TEXT_DB_NAME_ENV"
          value = var.db_name
        }

        env {
          name  = "AUDIO_TEXT_DB_USER_ENV"
          value = var.db_user
        }

        env {
          name  = "AUDIO_TEXT_DB_PASSWORD_ENV"
          value = random_password.db_password.result
        }

        env {
          name  = "AUDIO_TEXT_DB_PORT_ENV"
          value = "5432"
        }

        env {
          name  = "AUDIO_TEXT_REDIS_HOST_ENV"
          value = google_redis_instance.main.host
        }

        env {
          name  = "AUDIO_TEXT_REDIS_PORT_ENV"
          value = google_redis_instance.main.port
        }

        env {
          name  = "AUDIO_TEXT_AWS_BUCKET_NAME_ENV"
          value = var.create_audio_bucket ? google_storage_bucket.audio_files[0].name : var.audio_bucket_name
        }

        env {
          name  = "AUDIO_TEXT_AWS_REGION_ENV"
          value = var.region
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Worker is internal only (no public access)

