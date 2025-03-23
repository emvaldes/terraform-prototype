# File: /modules/gcp/compute/variables.tf
# Version: 0.1.0

variable "region" {
  description = "The GCP region where instances are deployed"
  type        = string
  default     = ""
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
}

variable "instance_type" {
  description = "Instance type for cloud resources"
  type        = string
}

variable "gcp_credentials" {
  description = "GCP credentials for authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "gcp_project_id" {
  description = "The Google Cloud Project ID"
  type        = string
  default     = ""
}

variable "network" {
  description = "VPC network ID"
  type        = string
}

variable "subnetwork" {
  description = "Subnet ID"
  type        = string
}
