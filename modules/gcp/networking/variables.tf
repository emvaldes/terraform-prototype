# File: /modules/gcp/networking/variables.tf
# Version: 0.1.0

variable "region" {
  description = "The GCP region where networking resources are deployed"
  type        = string
  default     = ""
}
