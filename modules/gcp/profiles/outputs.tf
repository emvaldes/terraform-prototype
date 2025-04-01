# File: modules/gcp/profiles/outputs.tf
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
  value       = google_service_account.cloud_function.email
}

output "cloud_function_service_account_unique_id" {
  description = "Unique ID of the Cloud Function service account"
  value       = google_service_account.cloud_function.unique_id
}
