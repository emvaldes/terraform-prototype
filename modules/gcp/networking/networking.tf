# File: /modules/gcp/networking/networking.tf
# Version: 0.1.0

resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_cidr_range
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_compute_global_address" "cloudsql_psa_range" {
  name          = var.psa_range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.psa_range_prefix
  network       = google_compute_network.vpc_network.id
}

resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
}

resource "google_service_networking_connection" "cloudsql_psa_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = google_project_service.servicenetworking.service
  reserved_peering_ranges = [google_compute_global_address.cloudsql_psa_range.name]
}
