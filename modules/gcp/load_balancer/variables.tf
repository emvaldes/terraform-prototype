# File: /modules/gcp/load_balancer/variables.tf
# Version: 0.1.0

variable "region" {
  description = "Region for the load balancer"
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

variable "instance_group" {
  description = "Instance group for backend services"
  type        = string
}

variable "http_forwarding_rule_name" {
  type        = string
  description = "Custom name for the global forwarding rule"
  default     = "http-forwarding-rule"
}

variable "web_backend_service_name" {
  type        = string
  description = "Custom name for the Web Backend-Service resource"
  default     = "web-backend-service"
}

variable "http_health_check_name" {
  type        = string
  description = "Custom name for the HTTP Health Check resource"
  default     = "http-health-check"
}
