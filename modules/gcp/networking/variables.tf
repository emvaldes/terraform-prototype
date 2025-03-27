# File: /modules/gcp/networking/variables.tf
# Version: 0.1.0

variable "region" {
  description = "The GCP region where networking resources are deployed"
  type        = string
  default     = ""
}

variable "gcp_project_id" {
  description = "The Google Cloud Project ID"
  type        = string
  default     = ""
}

variable "cloudsql_psa_prefix_length" {
  description = "Prefix length for Cloud SQL Private Service Access IP range"
  type        = number
  default     = 16
}

variable "cloudsql_psa_range_name" {
  description = "Name of the reserved IP range for Cloud SQL PSA"
  type        = string
  default     = "cloudsql-psa-range"
}
