# File: /modules/gcp/load_balancer/load_balancer.variables.tf
# Version: 0.1.2

# --- GCP Environment ---

variable "gcp_project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Region where resources will be deployed"
  type        = string
}

variable "network" {
  description = "VPC network name or self-link"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name or self-link"
  type        = string
}

# --- Backend Configuration ---

variable "instance_group" {
  description = "Self-link of the instance group to attach as backend"
  type        = string
}

variable "web_backend_service_name" {
  description = "Custom name for the Backend Service"
  type        = string
}

variable "web_backend_service_protocol" {
  description = "Protocol used by the Backend Service (e.g. HTTP)"
  type        = string
}

variable "web_backend_service_timeout" {
  description = "Timeout in seconds for the Backend Service"
  type        = number
}

# --- Health Check Configuration ---

variable "http_health_check_name" {
  description = "Name of the HTTP health check resource"
  type        = string
}

variable "http_health_check_interval" {
  description = "Interval between HTTP health checks (in seconds)"
  type        = number
}

variable "http_health_check_port" {
  description = "Port for HTTP health check"
  type        = number
}

variable "http_health_check_timeout" {
  description = "Timeout per health check (in seconds)"
  type        = number
}

# --- Forwarding Rule / Proxy / URL Map ---

variable "http_forwarding_port_range" {
  description = "Port range for forwarding rule (e.g. 80)"
  type        = string
}

variable "http_forwarding_rule_name" {
  description = "Name of the forwarding rule"
  type        = string
}

variable "http_forwarding_scheme" {
  description = "Load balancing scheme (e.g. EXTERNAL)"
  type        = string
}

variable "http_proxy_name" {
  description = "Name of the target HTTP proxy"
  type        = string
}

variable "url_map_name" {
  description = "Name of the URL map"
  type        = string
}

# Tagging Implementations

variable "load_balancer_tags" {
  type        = list(string)
  default     = []
  description = "Tags applied to load balancer components (if applicable)."
}
