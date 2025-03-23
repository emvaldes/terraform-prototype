# File: /modules/gcp/firewall/firewall.outputs.tf
# Version: 0.1.0

output "console_ips" {
  description = "GCP Console IPs"
  value       = var.console_ips
}

output "devops_ips" {
  description = "DevOps Remote IPs"
  value       = var.devops_ips
}

output "private_ips" {
  description = "Private Internal IPs"
  value       = var.private_ips
}

output "public_http_ranges" {
  description = "CIDR ranges allowed for public HTTP/HTTPS traffic"
  value       = var.public_http_ranges
}

# Tagging Implementations

output "allow_ssh_tags" {
  value       = var.allow_ssh_target_tags
  description = "Target tags for allow_ssh firewall rule."
}

output "allow_ssh_iap_tags" {
  value       = var.allow_ssh_iap_target_tags
  description = "Target tags for allow_ssh_iap firewall rule."
}
