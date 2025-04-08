# File: /locals.tf
# Version: 0.1.0

# Description: Contains all local values used across modules

locals {

  # Load dispatcher
  project = jsondecode(file("${path.root}/project.json"))

  # Active provider ID
  provider_id = local.project.defaults.provider

  # Provider config (cloud-specific)
  provider_default   = jsondecode(file("${path.root}/configs/providers/${local.provider_id}.json"))
  
  # Final provider config, overriding project_id if passed via env
  provider = merge(
    local.provider_default,
    {
      project_id = var.gcp_project_id
    }
  )

  # Use the overridden project_id
  project_id = local.provider.project_id

  # Workspace/target config (env-specific)
  workspace = jsondecode(file("${path.root}/configs/targets/${terraform.workspace}.json"))

  # Shared policies
  policies = jsondecode(file("${path.root}/configs/policies.json"))

  # Abstracted region/type from provider map
  region = lookup(local.provider.regions, local.workspace.region)
  type   = lookup(local.provider.types, local.workspace.type)

  # Load tagging map
  tagging = jsondecode(file("${path.root}/configs/tagging.json"))

  # Allowed Access (White listing)
  allowed = jsondecode(file("${path.root}/configs/allowed.json"))

  # GCP service naming map
  services = {
    for service in local.provider.services :
    service => jsondecode(
      file("${path.root}/configs/services/${local.provider.provider}/${service}.json")
    )
  }

  # Compute Resources (inject tags at creation time)
  compute_resources = merge(
    try(local.services.compute_resources, {}),
    {
      tags = [
        for tag in try(local.tagging.providers[local.provider_id].compute.tags, []) :
        tag.fixed ? tag.value : "${terraform.workspace}--${tag.value}"
      ]
    }
  )

  # Firewall Rules
  firewall_rules = merge(
    try(local.services.firewall_rules, {}),
    {
      tags = {
        allow_ssh = [
          for tag in try(local.tagging.providers[local.provider_id].firewall.allow_ssh.tags, []) :
          tag.fixed ? tag.value : "${terraform.workspace}--${tag.value}"
        ]
        allow_ssh_iap = [
          for tag in try(local.tagging.providers[local.provider_id].firewall.allow_ssh_iap.tags, []) :
          tag.fixed ? tag.value : "${terraform.workspace}--${tag.value}"
        ]
      }
    }
  )

  # GCP - Cloud Function (Stress-Load Testing)
  cloud_function = merge(
    try(local.services.cloud_function, {}),
    {
      tags = [
        for tag in try(local.tagging.providers[local.provider_id].cloud_function.tags, []) :
        tag.fixed ? tag.value : "${terraform.workspace}--${tag.value}"
      ]
    }
  )

  # Load-Balancer
  load_balancer = merge(
    try(local.services.load_balancer, {}),
    {
      tags = [
        for tag in try(local.tagging.providers[local.provider_id].load_balancer.tags, []) :
        tag.fixed ? tag.value : "${terraform.workspace}--${tag.value}"
      ]
    }
  )

  # Networking
  networking = merge(
    try(local.services.networking, {}),
    {
      tags = [
        for tag in try(local.tagging.providers[local.provider_id].networking.tags, []) :
        tag.fixed ? tag.value : "${terraform.workspace}--${tag.value}"
      ]
    }
  )

  # IAM Roles: Service Accounts
  profiles = merge(
    try(local.services.profiles, {}),
    {
      tags = [
        for tag in try(local.tagging.providers[local.provider_id].profiles.tags, []) :
        tag.fixed ? tag.value : "${terraform.workspace}--${tag.value}"
      ]
    }
  )

  # Autoscaling
  autoscaler = try(
    local.policies.autoscaling.profiles[local.workspace.policies.autoscaling],
    {}
  )

}
