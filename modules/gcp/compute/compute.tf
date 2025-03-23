# File: /modules/gcp/compute/compute.tf
# Version: 0.1.0

# Notes: Managed Instance Group (MIG) instead of standalone instances
#        * Switch to a Managed Instance Group (MIG) to allow ALB to distribute traffic automatically.
#        * Remove public IPs, since traffic should go through the ALB.
#        * Add a health check to monitor instance health behind the ALB.
# Terraform will create a Managed Instance Group (MIG) that dynamically manages instances behind the ALB.

# File: modules/gcp/compute/compute.tf

# Retrieve all available zones in the selected region
data "google_compute_zones" "available" {
  region = var.region
}

# Create an instance template for web servers
resource "google_compute_instance_template" "web_server" {
  name_prefix  = "web-server-template--"
  machine_type = var.instance_type
  region       = var.region

  disk {
    boot         = true
    auto_delete  = true
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  # Reference startup script from the global `/scripts/` directory
  metadata = {
    startup-script = file("${path.root}/scripts/setup-webserver.shell")
  }

  tags = [
    "ssh-access",
    "http-server",
    "couchsurfing"
  ]
}

# Create a Managed Instance Group (MIG) that distributes instances across available zones
resource "google_compute_region_instance_group_manager" "web_servers" {
  name               = "web-servers-group"
  base_instance_name = "web-server"
  region             = var.region

  # Distribute instances across all available zones
  distribution_policy_zones = data.google_compute_zones.available.names

  version {
    instance_template = google_compute_instance_template.web_server.id
  }

  target_size = var.instance_count
}

# Define a health check to ensure instances are healthy before being routed traffic
resource "google_compute_health_check" "http" {
  name               = "http-health-check-${var.region}" # Unique name per region
  check_interval_sec = 5
  timeout_sec        = 5

  http_health_check {
    port = 80
  }
}

# # Create multiple instances and distribute them across available zones
# resource "google_compute_instance" "web_server" {
#   count        = var.instance_count # Number of instances to create
#   name         = "web-server-${count.index}"
#   machine_type = var.instance_type
#   zone         = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]
#
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }
#
#   # network_interface {
#   #   network    = google_compute_network.vpc_network.id
#   #   subnetwork = google_compute_subnetwork.subnet.id
#   #   access_config {} # Assigns a public IP
#   # }
#   network_interface {
#     network    = var.network
#     subnetwork = var.subnetwork
#     access_config {}
#   }
#
#   tags = [
#     "ssh-access",
#     "http-server",
#     "couchsurfing"
#   ]
# }
