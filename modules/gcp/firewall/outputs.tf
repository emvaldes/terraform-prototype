# File: /modules/gcp/firewall/outputs.tf
# Version: 0.1.0

output "devops_ips" {
  description = "DevOps public IPs from allowed.json"
  value       = var.devops_ips
}

output "private_ips" {
  description = "Private IPs"
  value       = var.private_ips
}

output "console_ips" {
  description = "Console IPs"
  value       = var.console_ips
}
