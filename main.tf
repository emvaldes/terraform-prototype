# File: /main.tf
# Version: 0.1.0

terraform {
  required_version = ">= 1.3.0"
}

locals {
  config      = jsondecode(file("${path.root}/project.json"))
  allowed_ips = jsondecode(file("${path.root}/allowed.json"))
  targets     = jsondecode(file("${path.root}/workspaces.json"))

  workspace = lookup(
    local.targets.targets,
    terraform.workspace,
    local.targets.targets[local.targets.default]
  )
}

module "networking" {
  source = "./modules/gcp/networking"
  region = local.workspace.region
}

module "load_balancer" {
  source                    = "./modules/gcp/load_balancer"
  region                    = local.workspace.region
  network                   = module.networking.vpc_network_id
  subnetwork                = module.networking.subnet_id
  instance_group            = module.compute.web_servers_group
  http_forwarding_rule_name = local.workspace.services.http_forwarding.name
  web_backend_service_name  = local.workspace.services.web_backend.name
  http_health_check_name    = local.workspace.services.health_check.name
}

module "compute" {
  source          = "./modules/gcp/compute"
  region          = local.workspace.region
  instance_count  = local.workspace.count
  instance_type   = local.workspace.type
  gcp_credentials = var.gcp_credentials
  network         = module.networking.vpc_network_id
  subnetwork      = module.networking.subnet_id
  gcp_project_id  = var.gcp_project_id
}

module "firewall" {
  source      = "./modules/gcp/firewall"
  region      = local.workspace.region
  network     = module.networking.vpc_network_id
  devops_ips  = local.allowed_ips.devops_ips
  private_ips = local.allowed_ips.private_ips
  console_ips = local.allowed_ips.console_ips
}
