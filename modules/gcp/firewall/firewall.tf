# File: /modules/gcp/firewall/firewall.tf
# Version: 0.1.0

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-restricted"
  network = var.network
  # network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Allow SSH from public IPs, internal GCP network, and console IP range
  source_ranges = flatten([
    var.devops_ips,  # DevOps Public IPs from allowed.json
    var.private_ips, # ["10.0.0.0/8"],     # Hardcoded private IP
    var.console_ips, # ["35.235.240.0/20"] # Hardcoded console IP
  ])

  target_tags = ["ssh-access"]
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "allow-ssh-iap"
  network = var.network
  # network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Allow SSH through Google IAP
  # source_ranges = ["35.235.240.0/20"] # IAP IP Range
  source_ranges = var.console_ips
  target_tags   = ["ssh-access"]
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = var.network
  # network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
