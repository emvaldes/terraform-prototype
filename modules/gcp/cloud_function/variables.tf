# File: modules/gcp/cloud_function/variables.tf
# Version: 0.1.0

# Deployment Artifacts

variable "archive_name" {
  description = "Name of the zip archive for the function"
  type        = string
}

variable "archive_source" {
  description = "Path to the zip archive source"
  type        = string
}

variable "bucket_force_destroy" {
  description = "Whether to force destroy the bucket on deletion"
  type        = bool
}

variable "bucket_name" {
  description = "GCS bucket used to store the Cloud Function archive"
  type        = string
}

# Environment and Platform Settings

variable "environment_variables" {
  description = "Environment variables for the Cloud Function"
  type        = map(string)
}

variable "gcp_project_id" {
  description = "GCP project ID for deployment"
  type        = string
}

variable "region" {
  description = "The region where the Cloud Function is deployed"
  type        = string
}

variable "runtime" {
  description = "Runtime environment (e.g., python311)"
  type        = string
}

variable "service_account_email" {
  description = "Service account email used by the stressload Cloud Function"
  type        = string
}

# Cloud Function Configuration

variable "cloud_function_profile" {
  description = "IAM profile metadata for the Cloud Function"
  type        = any
}

variable "description" {
  description = "Description of the Cloud Function"
  type        = string
}

variable "entry_point" {
  description = "Handler entry point in the source code"
  type        = string
}

variable "function_name" {
  description = "Cloud Function name"
  type        = string
}

variable "memory" {
  description = "Memory allocation for the Cloud Function"
  type        = string
}

variable "timeout" {
  description = "Timeout (in seconds) for the Cloud Function"
  type        = number
}

# Trigger Configuration

variable "event_type" {
  description = "Event type for the trigger"
  type        = string
}

variable "pubsub_topic" {
  description = "Pub/Sub topic for event trigger (if applicable)"
  type        = string
}

# IAM Access

variable "invoker_member" {
  description = "IAM member allowed to invoke the function"
  type        = string
}

variable "invoker_role" {
  description = "IAM role for the function invoker"
  type        = string
}

# Stressload Settings

variable "stressload_config" {
  description = "Stressload settings based on selected level"
  type        = map(any)
}

variable "stressload_key" {
  description = "Stressload intensity level (e.g., low, medium, high)"
  type        = string
}

variable "stressload_log_level" {
  description = "Log level for stressload logging"
  type        = string
}

variable "stressload_policies" {
  description = "Stressload-specific policy config (levels + logging)"
  type        = any
}
