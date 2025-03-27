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
  name_prefix  = "${terraform.workspace}--web-server-template--"
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
  name               = "${terraform.workspace}--web-servers-group"
  base_instance_name = "web-server"
  region             = var.region

  # Distribute instances across all available zones
  distribution_policy_zones = data.google_compute_zones.available.names

  version {
    instance_template = google_compute_instance_template.web_server.id
  }

  target_size = var.instance_count
}

# resource "google_compute_region_autoscaler" "web_autoscaler" {
#   name   = "${terraform.workspace}--web-autoscaler"
#   region = var.region
#   target = google_compute_region_instance_group_manager.web_servers.id
#
#   autoscaling_policy {
#     max_replicas    = 5
#     min_replicas    = 1
#     cooldown_period = 60
#
#     cpu_utilization {
#       target = 0.6
#     }
#   }
# }

resource "google_compute_region_autoscaler" "web_autoscaler" {
  name   = "${terraform.workspace}--${var.web_autoscaler_name}"
  region = var.region
  target = google_compute_region_instance_group_manager.web_servers.id

  autoscaling_policy {
    max_replicas    = var.autoscaler_max_replicas # Prevent over-scaling and keep cost predictable
    min_replicas    = var.autoscaler_min_replicas # Ensure at least one instance is always running
    cooldown_period = var.autoscaler_cooldown     # Wait 60s after scaling before triggering again—reduces oscillation

    cpu_utilization {
      target = var.autoscaler_cpu_target # Scale out when average CPU exceeds 60% (default is 0.6 in GCP docs)
    }
  }
}

# Define a health check to ensure instances are healthy before being routed traffic
resource "google_compute_health_check" "http" {
  name               = "${terraform.workspace}--${var.http_health_check_name}-${var.region}" # Unique name per region
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
