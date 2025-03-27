# File: /providers.tf
# Version: 0.1.0

terraform {
  required_version = ">= 1.3.0"
}

# provider "google" {
#   credentials = base64decode(var.gcp_credentials) # Decode the base64-encoded JSON
#   region      = var.region
#   project     = jsondecode(base64decode(var.gcp_credentials)).project_id # Extract project_id correctly
# }

provider "google" {
  project = local.project.gcp.project
  region  = local.workspace.region
}
