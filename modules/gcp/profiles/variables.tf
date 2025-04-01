# File: modules/gcp/profiles/variables.tf
# Version: 0.1.0

variable "project_id" {
  description = "The GCP project ID where the service account will be created"
  type        = string
}

variable "readonly_service_account_name" {
  description = "The GCP Identity Access Management (IAM) Service Account name"
  type        = string
}

variable "cloud_function_service_account_name" {
  description = "Service account for ephemeral Cloud Function usage"
  type        = string
}

variable "cloud_function_service_account_display_name" {
  description = "Display name for the Cloud Function service account"
  type        = string
}
