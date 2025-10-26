# Cloud Storage bucket for frontend static files
resource "google_storage_bucket" "frontend" {
  name          = "${var.project_id}-frontend"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  cors {
    origin          = ["https://${var.frontend_subdomain}"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Make frontend bucket publicly readable
resource "google_storage_bucket_iam_member" "frontend_public" {
  bucket = google_storage_bucket.frontend.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Optional: Cloud Storage bucket for audio files (if not using AWS S3)
resource "google_storage_bucket" "audio_files" {
  count = var.create_audio_bucket ? 1 : 0

  name          = var.audio_bucket_name != "" ? var.audio_bucket_name : "${var.project_id}-audio-files"
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  cors {
    origin          = ["https://${var.api_subdomain}", "https://${var.frontend_subdomain}"]
    method          = ["GET", "POST", "PUT", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}
