# File: /main.tf
# Version: 0.1.0

terraform {
  required_version = ">= 1.3.0"
}

locals {

  project    = jsondecode(file("${path.root}/project.json"))
  allowed    = jsondecode(file("${path.root}/allowed.json"))
  workspaces = jsondecode(file("${path.root}/workspaces.json"))

  # Active provider (e.g., "gcp")
  provider_id = local.project.provider.default

  # Full provider object (e.g., local.project.provider.gcp)
  provider = lookup(local.project.provider, local.provider_id, {})

  # Environment-specific settings (workspace)
  workspace = lookup(
    local.workspaces.targets,
    terraform.workspace,
    local.workspaces.targets[local.workspaces.default]
  )

  # Abstracted region and type (resolve based on provider map)
  region = lookup(local.provider.regions, local.workspace.region)
  type   = lookup(local.provider.types, local.workspace.type)

  # Service names
  services = lookup(local.provider, "services", {})

  # Autoscaling policy
  autoscaler = try(local.workspace.policies.autoscaling, {})

  # Stressload policy name
  stressload_key = try(local.workspace.policies.stressload, "low")
  stressload     = try(local.workspaces.policies.stressload[local.stressload_key], {})

}

module "networking" {
  source         = "./modules/gcp/networking"
  region         = local.region
  gcp_project_id = var.gcp_project_id
}

module "load_balancer" {
  source                    = "./modules/gcp/load_balancer"
  network                   = module.networking.vpc_network_id
  subnetwork                = module.networking.subnet_id
  instance_group            = module.compute.web_servers_group
  region                    = local.workspace.region
  http_forwarding_rule_name = try(local.services.http_forwarding.name, null)
  web_backend_service_name  = local.services.web_backend.name
  http_health_check_name    = local.services.health_check.name
}

module "compute" {
  source                  = "./modules/gcp/compute"
  network                 = module.networking.vpc_network_id
  subnetwork              = module.networking.subnet_id
  region                  = local.region
  instance_type           = local.type
  instance_count          = try(local.autoscaler.min, 1)
  web_autoscaler_name     = local.services.web_autoscaling.name
  autoscaler_min_replicas = local.autoscaler.min
  autoscaler_max_replicas = local.autoscaler.max
  autoscaler_cpu_target   = local.autoscaler.threshold
  autoscaler_cooldown     = local.autoscaler.cooldown
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
