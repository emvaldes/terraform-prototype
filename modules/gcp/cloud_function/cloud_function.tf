# File: modules/gcp/cloud_function/cloud_function.tf
# Version: 0.1.0

resource "google_storage_bucket" "function_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = var.bucket_force_destroy
}

resource "google_storage_bucket_object" "function_archive" {
  # count  = var.auto_deploy ? 1 : 0
  count  = 1
  name   = var.archive_name
  bucket = google_storage_bucket.function_bucket.name
  source = var.archive_source
}

resource "google_cloudfunctions2_function" "cloud_function" {
  count       = var.auto_deploy ? 1 : 0
  name        = var.function_name
  location    = var.region
  description = var.description
  project     = var.gcp_project_id

  labels = {
    for tag in var.cloud_function_tags : tag => "true"
  }

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_archive[0].name
      }
    }
  }

  service_config {
    service_account_email = var.service_account_email
    available_memory      = var.memory
    timeout_seconds       = var.timeout
    environment_variables = var.environment_variables
    ingress_settings      = "ALLOW_ALL"
  }

  lifecycle {
    ignore_changes = [build_config[0].source[0].storage_source[0].generation]
  }
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  count          = var.auto_deploy ? 1 : 0
  project        = var.gcp_project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.cloud_function[0].name
  role           = var.invoker_role
  member         = var.invoker_member
}
