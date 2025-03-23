# File: /providers.tf
# Version: 0.1.0

terraform {
  required_version = ">= 1.3.0"

  ## Optional version pinning — uncomment if stability is required
  # required_providers {
  #   google = {
  #     source  = "hashicorp/google"
  #     version = ">= 6.29.0"
  #   }
  # }

}

provider "google" {
  project = local.project_id
  region  = local.region
}
