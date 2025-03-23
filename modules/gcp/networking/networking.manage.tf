# File: modules/gcp/networking/networking.manage.tf
# Version: 0.1.0

resource "google_compute_network" "management_vpc" {
  count                   = var.enable_management_vpc ? 1 : 0
  name                    = var.management_vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "management_subnet" {
  count                    = var.enable_management_vpc ? 1 : 0
  name                     = var.management_subnet_name
  ip_cidr_range            = var.management_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.management_vpc[0].id
  private_ip_google_access = true
}
