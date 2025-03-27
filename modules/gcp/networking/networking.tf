# File: /modules/gcp/networking/networking.tf
# Version: 0.1.0

resource "google_project_service" "servicenetworking" {
  project = var.gcp_project_id
  service = "servicenetworking.googleapis.com"

  disable_on_destroy = false
}

resource "google_compute_network" "vpc_network" {
  name                    = "${terraform.workspace}--webapp-vpc"
  auto_create_subnetworks = false
}

# Create a Subnet within the VPC
resource "google_compute_subnetwork" "subnet" {
  name          = "${terraform.workspace}--webapp-subnet"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_global_address" "cloudsql_psa_range" {
  name          = "${terraform.workspace}--cloudsql-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "cloudsql_psa_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.cloudsql_psa_range.name]

  depends_on = [
    google_project_service.servicenetworking
  ]
}
