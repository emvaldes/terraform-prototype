# File: modules/gcp/profiles/profiles.outputs.tf
# Version: 0.1.0

output "read_only_service_account_email" {
  description = "The email address of the read-only service account"
  value       = google_service_account.read_only.email
}

output "read_only_service_account_unique_id" {
  description = "The unique ID of the read-only service account"
  value       = google_service_account.read_only.unique_id
}

output "cloud_function_service_account_email" {
  description = "Email address of the ephemeral Cloud Function service account"
  value       = var.enable_cloud_function ? google_service_account.cloud_function[0].email : null
}

output "cloud_function_service_account_unique_id" {
  description = "Unique ID of the Cloud Function service account"
  value       = var.enable_cloud_function ? google_service_account.cloud_function[0].unique_id : null
}

# Tagging Implementations

output "profiles_tags" {
  value       = var.profiles_tags
  description = "Tags intended for profiles module (not applied due to Terraform limitations)."
}
