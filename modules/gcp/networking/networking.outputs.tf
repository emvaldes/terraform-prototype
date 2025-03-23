# File: /modules/gcp/networking/networking.outputs.tf
# Version: 0.1.0

output "cloudsql_psa_range_name" {
  description = "Name of the allocated Cloud SQL PSA range"
  value       = google_compute_global_address.cloudsql_psa_range.name
}

output "nat_name" {
  description = "Name of the Cloud NAT configuration"
  value       = google_compute_router_nat.nat_config.name
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.nat_router.name
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "management_vpc_id" {
  description = "ID of the optional Management VPC (if enabled)"
  value       = try(google_compute_network.management_vpc[0].id, null)
}

output "management_subnet_id" {
  description = "ID of the optional Management Subnet (if enabled)"
  value       = try(google_compute_subnetwork.management_subnet[0].id, null)
}

# Output: Management Subnet CIDR
output "management_subnet_cidr" {
  description = "CIDR block of the management subnet (if created)"
  value       = var.enable_management_vpc ? var.management_subnet_cidr : null
}

# Tagging Implementations

output "networking_tags" {
  value       = var.networking_tags
  description = "Networking tags (only applied to resources that support labels)."
}
