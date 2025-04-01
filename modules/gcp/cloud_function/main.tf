# File: modules/gcp/cloud_function/main.tf
# Version: 0.1.0

resource "google_storage_bucket" "function_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = var.bucket_force_destroy
}

resource "google_storage_bucket_object" "function_archive" {
  name   = var.archive_name
  bucket = google_storage_bucket.function_bucket.name
  source = var.archive_source
}

resource "google_cloudfunctions2_function" "cloud_function" {
  name        = var.function_name
  location    = var.region
  description = var.description
  project     = var.gcp_project_id

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_archive.name
      }
    }
  }

  service_config {
    service_account_email  = var.service_account_email
    available_memory       = var.memory
    timeout_seconds        = var.timeout
    environment_variables  = var.environment_variables
    ingress_settings       = "ALLOW_ALL"
  }

  lifecycle {
    ignore_changes = [build_config[0].source[0].storage_source[0].generation]
  }
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = var.gcp_project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.cloud_function.name
  role           = var.invoker_role
  member         = var.invoker_member
}
