# File: /modules/gcp/compute/compute.variables.tf
# Version: 0.1.0

# GCP Project and Region

variable "gcp_credentials" {
  description = "GCP credentials for authentication"
  type        = string
  sensitive   = true
}

variable "gcp_project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region where instances are deployed"
  type        = string
}

# Instance Template & MIG Settings

variable "base_instance_name" {
  description = "Base name for instances in the instance group"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create in the MIG"
  type        = number
}

variable "instance_group_name" {
  description = "Name of the regional managed instance group"
  type        = string
}

variable "instance_template_name_prefix" {
  description = "Prefix for the name of the instance template"
  type        = string
}

variable "instance_type" {
  description = "Machine type used in the instance template (e.g., e2-micro)"
  type        = string
}

variable "source_image" {
  description = "Source image used for the instance boot disk"
  type        = string
}

variable "startup_script_path" {
  description = "Path to the startup script file"
  type        = string
}

# Networking

variable "network" {
  description = "The ID of the VPC network"
  type        = string
}

variable "subnetwork" {
  description = "The ID of the subnet to attach instances to"
  type        = string
}

# Autoscaler Configuration

variable "autoscaler_cooldown" {
  description = "Cooldown period (in seconds) between autoscaling events"
  type        = number
}

variable "autoscaler_cpu_target" {
  description = "Target CPU utilization for autoscaling"
  type        = number
}

variable "autoscaler_max_replicas" {
  description = "Maximum number of instances in the autoscaler group"
  type        = number
}

variable "autoscaler_min_replicas" {
  description = "Minimum number of instances in the autoscaler group"
  type        = number
}

variable "web_autoscaler_name" {
  description = "Name of the regional autoscaler resource"
  type        = string
}

# Health Check

variable "health_check_interval" {
  description = "Interval between health checks (in seconds)"
  type        = number
}

variable "health_check_name" {
  description = "Name of the HTTP health check resource"
  type        = string
}

variable "health_check_port" {
  description = "Port used for the HTTP health check"
  type        = number
}

variable "health_check_timeout" {
  description = "Timeout for each health check attempt (in seconds)"
  type        = number
}

# Update Policy Strategy (Surge/Unavailable)

variable "max_surge" {
  description = "Max surge strategy (percent or fixed)"
  type        = any
  default     = {}
}

variable "max_unavail" {
  description = "Max unavailable strategy (percent or fixed)"
  type        = any
  default     = {}
}

# Tagging Implementations

variable "instance_tags" {
  type        = list(string)
  default     = []
  description = "List of network tags to apply to compute instances (used for firewall rules, load balancing, etc.). Sourced from tagging.json."
}
