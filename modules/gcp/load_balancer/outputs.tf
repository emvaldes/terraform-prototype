# File: /modules/gcp/load_balancer/outputs.tf
# Version: 0.1.0

output "load_balancer_ip" {
  description = "Public IP address of the global forwarding rule"
  value       = google_compute_global_forwarding_rule.http.ip_address
}

output "http_forwarding_rule_name" {
  description = "Name of the global HTTP Forwarding Rule"
  value       = google_compute_global_forwarding_rule.http.name
}

output "web_backend_service_name" {
  description = "Name of the Web Backend-Service"
  value       = google_compute_backend_service.web_backend.name
}

output "http_health_check_name" {
  description = "Name of the health check"
  value       = google_compute_health_check.http.name
}
