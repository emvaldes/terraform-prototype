# File: /modules/gcp/load_balancer/main.tf
# Version: 0.1.0

# Health Check
resource "google_compute_health_check" "http" {
  name               = var.http_health_check_name
  check_interval_sec = var.http_health_check_interval
  timeout_sec        = var.http_health_check_timeout

  http_health_check {
    port = var.http_health_check_port
  }
}

# Backend Service
resource "google_compute_backend_service" "web_backend" {
  name                  = var.web_backend_service_name
  load_balancing_scheme = var.http_forwarding_scheme
  protocol              = var.web_backend_service_protocol
  timeout_sec           = var.web_backend_service_timeout
  health_checks         = [google_compute_health_check.http.id]

  backend {
    group = var.instance_group
  }
}

# URL Map
resource "google_compute_url_map" "default" {
  name            = var.url_map_name
  default_service = google_compute_backend_service.web_backend.id
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  name    = var.http_proxy_name
  url_map = google_compute_url_map.default.id
}

# Forwarding Rule
resource "google_compute_global_forwarding_rule" "http" {
  name                  = var.http_forwarding_rule_name
  target                = google_compute_target_http_proxy.default.id
  load_balancing_scheme = var.http_forwarding_scheme
  port_range            = var.http_forwarding_port_range
}
