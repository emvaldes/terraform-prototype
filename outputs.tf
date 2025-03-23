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
  description = "DevOps public IPs from allowed.json"
  value       = module.firewall.devops_ips
}

output "private_ips" {
  description = "Private IPs from allowed.json"
  value       = module.firewall.private_ips
}

output "console_ips" {
  description = "Console IPs from allowed.json"
  value       = module.firewall.console_ips
}

output "web_server_ip" {
  description = "Public IPs of the web servers"
  value       = module.compute.web_server_ip
}

output "load_balancer_ip" {
  value = module.load_balancer.load_balancer_ip
}

output "forwarding_rule_name" {
  value = module.load_balancer.http_forwarding_rule_name
}

output "web_backend_service_name" {
  value = module.load_balancer.web_backend_service_name
}

output "http_health_check_name" {
  value = module.load_balancer.http_health_check_name
}
