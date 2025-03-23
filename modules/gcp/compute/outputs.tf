# File: /modules/gcp/compute/outputs.tf
# Version: 0.1.0

output "instance_type" {
  description = "Instance type for cloud resources"
  value       = var.instance_type
}

# Fetch instances from the Regional Managed Instance Group (MIG)
data "google_compute_region_instance_group_manager" "web_servers" {
  name    = google_compute_region_instance_group_manager.web_servers.name
  project = var.gcp_project_id
  region  = var.region
}

output "web_server_ip" {
  description = "Public IPs of the web servers"
  value       = data.google_compute_region_instance_group_manager.web_servers.instance_group
}

output "web_servers_group" {
  description = "Instance group for web servers"
  value       = google_compute_region_instance_group_manager.web_servers.instance_group
}
