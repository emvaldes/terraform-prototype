# File: /outputs.tf
# Version: 0.1.0

output "region" {
  description = "The region where resources are deployed"
  value       = module.networking.region
}

output "instance_type" {
  description = "Instance type used for deployment"
  value       = module.compute.instance_type
}

output "devops_ips" {
  description = "DevOps Remote IPs"
  value       = module.firewall.devops_ips
}

output "private_ips" {
  description = "Private Internal IPs"
  value       = module.firewall.private_ips
}

output "console_ips" {
  description = "GCP Console IPs"
  value       = module.firewall.console_ips
}

output "web_server_ip" {
  description = "Public IPs of the web servers"
  value       = module.compute.web_server_ip
}

output "load_balancer_ip" {
  description = "Application Loadbalancer IP address"
  value       = module.load_balancer.load_balancer_ip
}

output "forwarding_rule_name" {
  description = "HTTP Forwarding Rule name"
  value       = module.load_balancer.http_forwarding_rule_name
}

output "web_backend_service_name" {
  description = "Web Backend-Service name"
  value       = module.load_balancer.web_backend_service_name
}

output "http_health_check_name" {
  description = "HTTP Health Check name"
  value       = module.load_balancer.http_health_check_name
}
