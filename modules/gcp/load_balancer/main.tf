# File: /modules/gcp/load_balancer/main.tf
# Version: 0.1.0

# Define health check for ALB to monitor instance health
resource "google_compute_health_check" "http" {
  name               = "${terraform.workspace}--${var.http_health_check_name}" # "http-health-check"
  check_interval_sec = 5
  timeout_sec        = 5

  http_health_check {
    port = 80
  }
}

# Backend Service that connects to instance group
resource "google_compute_backend_service" "web_backend" {
  name                  = "${terraform.workspace}--${var.web_backend_service_name}" # "web-backend-service"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.http.id]

  backend {
    group = var.instance_group # Use the instance group passed from compute
  }
}

resource "google_compute_url_map" "default" {
  name            = "${terraform.workspace}--web-url-map"
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${terraform.workspace}--web-http-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${terraform.workspace}--${var.http_forwarding_rule_name}" # "http-forwarding-rule"
  target                = google_compute_target_http_proxy.default.id
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
}
