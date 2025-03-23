# File: /modules/gcp/firewall/variables.tf
# Version: 0.1.0

variable "region" {
  description = "The GCP region where firewall rules are applied"
  type        = string
  default     = ""
}

variable "devops_ips" {
  description = "DevOps public IPs from allowed.json"
  type        = list(string)
}

variable "private_ips" {
  description = "Internal Private IPs from allowed.json"
  type        = list(string)
}

variable "console_ips" {
  description = "GCP Console IPs from allowed.json"
  type        = list(string)
}

variable "network" {
  description = "VPC network ID"
  type        = string
}
