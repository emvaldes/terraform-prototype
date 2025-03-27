# File: /main.tf
# Version: 0.1.0

terraform {
  required_version = ">= 1.3.0"
}

locals {
  project    = jsondecode(file("${path.root}/project.json"))
  allowed    = jsondecode(file("${path.root}/allowed.json"))
  workspaces = jsondecode(file("${path.root}/workspaces.json"))

  services = local.project.services

  workspace = lookup(
    local.workspaces.targets,
    terraform.workspace,
    local.workspaces.targets[local.workspaces.default]
  )

}

module "networking" {
  source         = "./modules/gcp/networking"
  region         = local.workspace.region
  gcp_project_id = var.gcp_project_id
}

module "load_balancer" {
  source                    = "./modules/gcp/load_balancer"
  network                   = module.networking.vpc_network_id
  subnetwork                = module.networking.subnet_id
  instance_group            = module.compute.web_servers_group
  region                    = local.workspace.region
  http_forwarding_rule_name = local.services.http_forwarding.name
  web_backend_service_name  = local.services.web_backend.name
  http_health_check_name    = local.services.health_check.name
}

module "compute" {
  source                  = "./modules/gcp/compute"
  network                 = module.networking.vpc_network_id
  subnetwork              = module.networking.subnet_id
  region                  = local.workspace.region
  instance_count          = local.workspace.count
  instance_type           = local.workspace.type
  web_autoscaler_name     = local.services.autoscaler.name
  autoscaler_min_replicas = local.services.autoscaler.min
  autoscaler_max_replicas = local.services.autoscaler.max
  autoscaler_cpu_target   = local.services.autoscaler.cpu_target
  autoscaler_cooldown     = local.services.autoscaler.cooldown
  http_health_check_name  = local.services.health_check.name
  gcp_credentials         = var.gcp_credentials
  gcp_project_id          = var.gcp_project_id
}

module "firewall" {
  source      = "./modules/gcp/firewall"
  network     = module.networking.vpc_network_id
  region      = local.workspace.region
  devops_ips  = local.allowed.devops_ips
  private_ips = local.allowed.private_ips
  console_ips = local.allowed.console_ips
}
