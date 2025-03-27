# File: /providers.tf
# Version: 0.1.0

terraform {
  required_version = ">= 1.3.0"
}

provider "google" {
  project = local.provider.project
  region  = local.region
}
