# File: /modules/gcp/networking/networking.tf
# Version: 0.1.0

resource "google_compute_network" "vpc_network" {
  name                    = "webapp-vpc"
  auto_create_subnetworks = false
}

# Create a Subnet within the VPC
resource "google_compute_subnetwork" "subnet" {
  name          = "webapp-subnet"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.1.0/24"
}
