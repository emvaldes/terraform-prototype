# File: /modules/gcp/compute/compute.tf
# Version: 0.1.0

# Retrieve all available zones in the selected region
data "google_compute_zones" "available" {
  region = var.region
}

# Create an instance template for web servers
resource "google_compute_instance_template" "web_server" {
  name_prefix  = var.instance_template_name_prefix
  machine_type = var.instance_type
  region       = var.region

  disk {
    boot         = true
    auto_delete  = true
    source_image = var.source_image
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  metadata = {
    startup-script = file(var.startup_script_path)
  }

  tags = var.instance_tags
}

# Create a Managed Instance Group (MIG) that distributes instances across available zones
resource "google_compute_region_instance_group_manager" "web_servers" {
  name               = var.instance_group_name
  base_instance_name = var.base_instance_name
  region             = var.region

  distribution_policy_zones = data.google_compute_zones.available.names

  version {
    instance_template = google_compute_instance_template.web_server.id
  }

  target_size = var.instance_count
}

# Define autoscaler configuration
resource "google_compute_region_autoscaler" "web_autoscaler" {
  name   = var.web_autoscaler_name
  region = var.region
  target = google_compute_region_instance_group_manager.web_servers.id

  autoscaling_policy {
    max_replicas    = var.autoscaler_max_replicas
    min_replicas    = var.autoscaler_min_replicas
    cooldown_period = var.autoscaler_cooldown

    cpu_utilization {
      target = var.autoscaler_cpu_target
    }
  }
}

# Define a health check to ensure instances are healthy before being routed traffic
resource "google_compute_health_check" "http" {
  name               = var.health_check_name
  check_interval_sec = var.health_check_interval
  timeout_sec        = var.health_check_timeout

  http_health_check {
    port = var.health_check_port
  }
}
