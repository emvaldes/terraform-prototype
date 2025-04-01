# File: /modules/gcp/load_balancer/outputs.tf
# Version: 0.1.0

output "http_forwarding_rule_name" {
  description = "Name of the HTTP forwarding rule"
  value       = google_compute_global_forwarding_rule.http.name
}

output "load_balancer_ip" {
  description = "Public IP address of the global forwarding rule"
  value       = google_compute_global_forwarding_rule.http.ip_address
}

output "web_backend_service_name" {
  description = "Name of the backend service"
  value       = google_compute_backend_service.web_backend.name
}

output "http_health_check_name" {
  description = "Name of the health check"
  value       = google_compute_health_check.http.name
}
