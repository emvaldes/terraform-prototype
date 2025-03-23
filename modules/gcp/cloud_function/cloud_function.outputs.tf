# File: modules/gcp/cloud_function/cloud_function.outputs.tf
# Version: 0.1.0

# Deployment Artifacts

output "function_bucket" {
  description = "The GCS bucket used to deploy the function"
  value       = google_storage_bucket.function_bucket.name
}

output "function_name" {
  description = "The name of the deployed Cloud Function"
  value       = var.auto_deploy ? google_cloudfunctions2_function.cloud_function[0].name : null
}

output "function_region" {
  description = "Region where the function is deployed"
  value       = var.auto_deploy ? google_cloudfunctions2_function.cloud_function[0].location : null
}

output "function_url" {
  description = "The HTTPS trigger URL for the Cloud Function"
  value       = var.auto_deploy ? google_cloudfunctions2_function.cloud_function[0].service_config[0].uri : null
}

output "upload_target" {
  description = "Terraform target path for uploading the Cloud Function archive"
  value       = "module.cloud_function[0].google_storage_bucket_object.function_archive"
}

# Stressload Metadata (Resolved Inputs)

output "stressload_config" {
  value       = var.stressload_config
  description = "Resolved stressload config for this deployment"
}

output "stressload_key" {
  value       = var.stressload_key
  description = "Stressload key for policy level (e.g., low, medium)"
}

output "stressload_log_level" {
  value       = var.stressload_log_level
  description = "Log level for the stress tester"
}

# Cloud Function Metadata (Reflected Inputs)

output "stressload_function_bucket" {
  value       = var.bucket_name
  description = "Bucket name where the stressload Cloud Function archive is stored"
}

output "stressload_function_name" {
  value       = var.function_name
  description = "Name of the stressload Cloud Function"
}

output "stressload_function_region" {
  value       = var.region
  description = "Region where the stressload Cloud Function is deployed"
}

output "stressload_function_service_account_email" {
  value       = var.service_account_email
  description = "Service account email for the deployed stressload Cloud Function"
}

# Tagging Implementations

output "cloud_function_tags" {
  value       = var.cloud_function_tags
  description = "Tags applied to the Cloud Function."
}
