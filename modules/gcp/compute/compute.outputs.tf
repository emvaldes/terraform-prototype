# File: /modules/gcp/compute/compute.outputs.tf
# Version: 0.1.0

output "instance_type" {
  description = "Instance type for cloud resources"
  value       = var.instance_type
}

output "web_servers_group" {
  description = "Instance group for web servers"
  value       = google_compute_region_instance_group_manager.web_servers.instance_group
}

output "web_server_ip" {
  description = "Managed instance group URI used as web server backend"
  value       = google_compute_region_instance_group_manager.web_servers.instance_group
}

output "instance_template" {
  description = "The self_link of the created instance template"
  value       = google_compute_instance_template.web_server.self_link
}

output "web_autoscaler_name" {
  description = "Name of the autoscaler resource"
  value       = google_compute_region_autoscaler.web_autoscaler.name
}

# Tagging Implementations

output "instance_tags" {
  value       = var.instance_tags
  description = "Tags applied to the compute instances."
}
