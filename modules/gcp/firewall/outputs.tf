# File: /modules/gcp/firewall/outputs.tf
# Version: 0.1.0

output "devops_ips" {
  description = "DevOps Remote IPs"
  value       = var.devops_ips
}

output "private_ips" {
  description = "Private Internal IPs"
  value       = var.private_ips
}

output "console_ips" {
  description = "GCP Console IPs"
  value       = var.console_ips
}
