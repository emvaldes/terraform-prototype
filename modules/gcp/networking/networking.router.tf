# File: /modules/gcp/networking/router.tf
# Version: 0.1.0

resource "google_compute_router" "nat_router" {
  name    = var.router_name
  region  = var.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat_config" {
  name                               = var.nat_name
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  enable_endpoint_independent_mapping = true
  tcp_established_idle_timeout_sec    = var.tcp_established_timeout_sec
  tcp_transitory_idle_timeout_sec     = var.tcp_transitory_timeout_sec
  udp_idle_timeout_sec                = var.udp_idle_timeout_sec
  icmp_idle_timeout_sec               = var.icmp_idle_timeout_sec

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
