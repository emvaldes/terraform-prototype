# File: modules/gcp/profiles/profiles.tf
# Version: 0.1.0

resource "google_service_account" "read_only" {
  account_id   = var.readonly_service_account_name
  display_name = "Read-Only Service Account for ${terraform.workspace}"

  # labels = {
  #   for tag in var.profiles_tags : tag => "true"
  # }

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_project_iam_member" "compute_viewer" {
  project = var.gcp_project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.read_only.email}"
}

resource "google_project_iam_member" "monitoring_viewer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.read_only.email}"
}

resource "google_project_iam_member" "logging_viewer" {
  project = var.gcp_project_id
  role    = "roles/logging.viewer"
  member  = "serviceAccount:${google_service_account.read_only.email}"
}

# Cloud Function Ephemeral Service Account

resource "google_service_account" "cloud_function" {

  count        = var.enable_cloud_function ? 1 : 0
  account_id   = var.cloud_function_service_account_name
  display_name = var.cloud_function_service_account_display_name

  # labels = {
  #   for tag in var.profiles_tags : tag => "true"
  # }
  lifecycle {
    prevent_destroy = false
  }

}

resource "google_project_iam_member" "cloud_function_compute_viewer" {

  count   = var.enable_cloud_function ? 1 : 0
  project = var.gcp_project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.cloud_function[0].email}"

}

resource "google_project_iam_member" "cloud_function_monitoring_viewer" {

  count   = var.enable_cloud_function ? 1 : 0
  project = var.gcp_project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.cloud_function[0].email}"

}

resource "google_project_iam_member" "cloud_function_logging_viewer" {

  count   = var.enable_cloud_function ? 1 : 0
  project = var.gcp_project_id
  role    = "roles/logging.viewer"
  member  = "serviceAccount:${google_service_account.cloud_function[0].email}"
}

# CLI Admin Service Account - Logging Viewer

resource "google_project_iam_member" "cli_admin_logging_viewer" {
  project = var.gcp_project_id
  role    = "roles/logging.viewer"
  member  = "serviceAccount:gcp-cli-admin@${var.gcp_project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "cli_admin_storage_admin" {
  project = var.gcp_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:gcp-cli-admin@${var.gcp_project_id}.iam.gserviceaccount.com"
}
