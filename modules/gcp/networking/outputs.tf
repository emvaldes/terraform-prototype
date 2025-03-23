# File: /modules/gcp/networking/outputs.tf
# Version: 0.1.0

output "region" {
  description = "The GCP region for networking"
  value       = var.region
}

output "vpc_network_id" {
  description = "VPC network ID"
  value       = google_compute_network.vpc_network.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = google_compute_subnetwork.subnet.id
}
