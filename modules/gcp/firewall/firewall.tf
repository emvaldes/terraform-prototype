# File: /modules/gcp/firewall/firewall.tf
# Version: 0.1.0

resource "google_compute_firewall" "allow_ssh" {
  name    = var.allow_ssh_name
  network = var.network

  allow {
    protocol = var.allow_ssh_protocol
    ports    = var.allow_ssh_ports
  }

  # Allow SSH from public IPs, internal GCP network, and console IP range
  source_ranges = flatten([
    var.devops_ips,  # DevOps Public IPs from allowed.json
    var.private_ips, # ["10.0.0.0/8"],     # Hardcoded private IP
    var.console_ips, # ["35.235.240.0/20"] # Hardcoded console IP
  ])

  target_tags = var.allow_ssh_target_tags

}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = var.allow_ssh_iap_name
  network = var.network

  allow {
    protocol = var.allow_ssh_iap_protocol
    ports    = var.allow_ssh_iap_ports
  }

  # Allow SSH through Google IAP
  # source_ranges = ["35.235.240.0/20"] # IAP IP Range
  source_ranges = var.console_ips

  target_tags = var.allow_ssh_iap_target_tags

}

resource "google_compute_firewall" "allow_http_https" {
  name    = var.allow_http_https_name
  network = var.network

  allow {
    protocol = var.allow_http_https_protocol
    ports    = var.allow_http_https_ports
  }

  source_ranges = var.public_http_ranges
}
