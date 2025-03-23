# File: /backend.tf
# Version: 0.1.0

terraform {
  backend "gcs" {
    bucket = "multi-cloud-terraform-state"
    prefix = "terraform/state"
  }
}
