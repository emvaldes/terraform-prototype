# File: /modules/gcp/firewall/firewall.variables.tf
# Version: 0.1.0

variable "allow_http_https_name" {
  description = "Name of the HTTP/HTTPS firewall rule"
  type        = string
}

variable "allow_http_https_ports" {
  description = "List of allowed ports for HTTP/HTTPS"
  type        = list(string)
}

variable "allow_http_https_protocol" {
  description = "Protocol for the HTTP/HTTPS rule"
  type        = string
}

variable "allow_ssh_iap_name" {
  description = "Name of the IAP SSH firewall rule"
  type        = string
}

variable "allow_ssh_iap_ports" {
  description = "List of allowed ports for IAP SSH"
  type        = list(string)
}

variable "allow_ssh_iap_protocol" {
  description = "Protocol for IAP SSH rule"
  type        = string
}

variable "allow_ssh_name" {
  description = "Name of the SSH firewall rule"
  type        = string
}

variable "allow_ssh_ports" {
  description = "List of allowed ports for SSH"
  type        = list(string)
}

variable "allow_ssh_protocol" {
  description = "Protocol for SSH rule"
  type        = string
}

variable "console_ips" {
  description = "Allowed GCP console IPs"
  type        = list(string)
}

variable "devops_ips" {
  description = "Allowed DevOps public IPs"
  type        = list(string)
}

variable "network" {
  description = "VPC network ID"
  type        = string
}

variable "private_ips" {
  description = "Allowed internal private IPs"
  type        = list(string)
}

variable "public_http_ranges" {
  description = "Public CIDR blocks allowed for HTTP/HTTPS traffic"
  type        = list(string)
}

# Tagging Implementations

variable "allow_ssh_target_tags" {
  type        = list(string)
  default     = []
  description = "SSH Rule: Network tags assigned to the 'allow_ssh' firewall rule targets. Sourced from tagging.json."
}

variable "allow_ssh_iap_target_tags" {
  type        = list(string)
  default     = []
  description = "IAP SSH Rule: Network tags assigned to the 'allow_ssh_iap' firewall rule targets. Sourced from tagging.json."
}
