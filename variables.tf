# File: /variables.tf
# Version: 0.1.0

variable "gcp_credentials" {
  description = "The credentials (can be base64 encoded JSON)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "region" {
  description = "Deployment region"
  type        = string
  default     = ""
}

variable "project_config" {
  description = "Configuration loaded from project.json"
  type        = string
  default     = ""
}

variable "gcp_project_id" {
  description = "The Google Cloud Project ID"
  type        = string
  default     = ""
}
