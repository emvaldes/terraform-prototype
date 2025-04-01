# File: /modules/gcp/networking/variables.tf
# Version: 0.1.1

# Project & Region Configuration

variable "gcp_project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region where networking resources are deployed"
  type        = string
}

# VPC & Subnet Configuration

variable "vpc_network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "subnet_cidr_range" {
  description = "CIDR range for the subnet (e.g., 10.0.1.0/24)"
  type        = string
}

# Private Service Access (PSA) Configuration

variable "psa_range_name" {
  description = "Name of the Cloud SQL PSA range"
  type        = string
}

variable "psa_range_prefix" {
  description = "Prefix length for the PSA range (e.g., 16)"
  type        = number
}

# Router & NAT Configuration

variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
}

variable "nat_name" {
  description = "Name of the Cloud NAT configuration"
  type        = string
}

# NAT Timeouts

variable "tcp_established_timeout_sec" {
  description = "Idle timeout for established TCP connections (in seconds)"
  type        = number
}

variable "tcp_transitory_timeout_sec" {
  description = "Idle timeout for transitory TCP connections (in seconds)"
  type        = number
}

variable "udp_idle_timeout_sec" {
  description = "Idle timeout for UDP connections (in seconds)"
  type        = number
}

variable "icmp_idle_timeout_sec" {
  description = "Idle timeout for ICMP connections (in seconds)"
  type        = number
}

variable "enable_management_vpc" {
  description = "Whether to create a separate management VPC (on-demand)"
  type        = bool
  default     = false
}

variable "management_vpc_name" {
  description = "Name of the management VPC (optional)"
  type        = string
}

variable "management_subnet_name" {
  description = "Name of the management subnet"
  type        = string
}

variable "management_subnet_cidr" {
  description = "CIDR range for the management subnet (e.g., 10.90.0.0/24)"
  type        = string
}

variable "management_private_ip_google_access" {
  description = "Enable Private Google Access for management subnet"
  type        = bool
}
