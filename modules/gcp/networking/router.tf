# File: modules/gcp/networking/router.tf
# Version: 0.1.0

resource "google_compute_router" "nat_router" {
  name    = "${terraform.workspace}--webapp-router"
  region  = var.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat_config" {
  name                               = "${terraform.workspace}--webapp-nat-config"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  enable_endpoint_independent_mapping = true

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
