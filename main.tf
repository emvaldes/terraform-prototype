# File: /main.tf
# Version: 0.1.0

terraform {

  required_version = ">= 1.3.0"

}

locals {

  # Load dispatcher
  project = jsondecode(file("${path.root}/project.json"))

  # Active provider ID
  provider_id = local.project.default

  # Provider config (cloud-specific)
  provider = jsondecode(file("${path.root}/configs/project/${local.provider_id}.json"))

  # Workspace/target config (env-specific)
  workspace = jsondecode(file("${path.root}/configs/targets/${terraform.workspace}.json"))

  # Shared policies
  policies = jsondecode(file("${path.root}/configs/policies.json"))

  # Abstracted region/type from provider map
  region = lookup(local.provider.regions, local.workspace.region)
  type   = lookup(local.provider.types, local.workspace.type)

  # GCP service naming map
  services = try(local.provider.services, {})

  # GCP - Cloud Function (Stress-Load Testing)
  cloud_function = local.services.cloud_function

  # Compute Resources
  compute_resources = local.services.compute_resources

  # Firewall Rules
  firewall_rules = local.services.firewall_rules

  # Load-Balancer
  load_balancer = local.services.load_balancer

  # Networking
  networking = local.services.networking

  # Autoscaling
  autoscaler = try(local.workspace.policies.autoscaling, {})

  # Allowed Access (White listing)
  allowed = jsondecode(file("${path.root}/configs/allowed.json"))

}

module "cloud_function" {

  source = "./modules/gcp/cloud_function"

  gcp_project_id = var.gcp_project_id
  region         = local.region

  bucket_name    = "${terraform.workspace}--${local.cloud_function.bucket_name}"
  archive_source = "${local.cloud_function.archive_path}/${local.cloud_function.archive_name}"

  function_name         = "${terraform.workspace}--${local.cloud_function.name}"
  description           = local.cloud_function.description
  entry_point           = local.cloud_function.entry_point
  runtime               = local.cloud_function.runtime
  memory                = local.cloud_function.memory
  timeout               = local.cloud_function.timeout
  environment_variables = local.cloud_function.env

  event_type   = local.cloud_function.event_type
  pubsub_topic = local.cloud_function.pubsub_topic

  archive_name         = "${terraform.workspace}--${local.cloud_function.archive_name}"
  bucket_force_destroy = try(local.cloud_function.force_destroy, true)

  invoker_role   = try(local.cloud_function.invoker_role, "roles/cloudfunctions.invoker")
  invoker_member = try(local.cloud_function.invoker_member, "allUsers")

  service_account_email = module.profiles.cloud_function_service_account_email

  stressload_key         = try(local.workspace.policies.stressload, "low")
  stressload_config      = try(local.policies.stressload.levels[local.workspace.policies.stressload], {})
  stressload_log_level   = try(local.policies.stressload.logging.log_level, "info")
 
  stressload_policies = local.policies.stressload
  cloud_function_profile = local.policies.profiles.cloud_function

}

# https://console.cloud.google.com/apis/api/compute.googleapis.com/metrics?authuser=1&invt=AbtQvg&project=<gcp-project-id>
module "compute" {

  source         = "./modules/gcp/compute"
  region         = local.region
  instance_count = try(local.autoscaler.min, 1)
  instance_type  = local.type

  gcp_credentials = var.gcp_credentials
  gcp_project_id  = var.gcp_project_id

  network    = module.networking.vpc_network_id
  subnetwork = module.networking.subnet_id

  web_autoscaler_name     = "${terraform.workspace}--${local.services.web_autoscaling.name}"
  autoscaler_min_replicas = local.autoscaler.min
  autoscaler_max_replicas = local.autoscaler.max
  autoscaler_cpu_target   = local.autoscaler.threshold
  autoscaler_cooldown     = local.autoscaler.cooldown

  instance_template_name_prefix = "${terraform.workspace}--${local.compute_resources.instance_template_name_prefix}"
  instance_group_name           = "${terraform.workspace}--${local.compute_resources.instance_group_name}"
  base_instance_name            = "${terraform.workspace}--${local.compute_resources.base_instance_name}"

  source_image        = local.compute_resources.source_image
  startup_script_path = "${path.root}/${local.compute_resources.startup_script_path}"
  instance_tags       = local.compute_resources.instance_tags

  health_check_name     = "${terraform.workspace}--${local.services.health_check.name}-${local.region}"
  health_check_interval = local.compute_resources.health_check.interval
  health_check_timeout  = local.compute_resources.health_check.timeout
  health_check_port     = local.compute_resources.health_check.port

}

module "firewall" {

  source  = "./modules/gcp/firewall"
  network = module.networking.vpc_network_id

  devops_ips         = local.allowed.devops_ips
  private_ips        = local.allowed.private_ips
  console_ips        = local.allowed.console_ips
  public_http_ranges = try(local.firewall_rules.public_http_ranges, ["0.0.0.0/0"])

  allow_ssh_name        = "${terraform.workspace}--${local.firewall_rules.allow_ssh.name}"
  allow_ssh_protocol    = local.firewall_rules.allow_ssh.protocol
  allow_ssh_ports       = local.firewall_rules.allow_ssh.ports
  allow_ssh_target_tags = local.firewall_rules.allow_ssh.target_tags

  allow_ssh_iap_name        = "${terraform.workspace}--${local.firewall_rules.allow_ssh_iap.name}"
  allow_ssh_iap_protocol    = local.firewall_rules.allow_ssh_iap.protocol
  allow_ssh_iap_ports       = local.firewall_rules.allow_ssh_iap.ports
  allow_ssh_iap_target_tags = local.firewall_rules.allow_ssh_iap.target_tags

  allow_http_https_name     = "${terraform.workspace}--${local.firewall_rules.allow_http_https.name}"
  allow_http_https_protocol = local.firewall_rules.allow_http_https.protocol
  allow_http_https_ports    = local.firewall_rules.allow_http_https.ports

}

module "load_balancer" {

  source         = "./modules/gcp/load_balancer"
  gcp_project_id = var.gcp_project_id
  region         = local.region
  network        = module.networking.vpc_network_id
  subnetwork     = module.networking.subnet_id
  instance_group = module.compute.web_servers_group

  http_forwarding_rule_name  = "${terraform.workspace}--${local.load_balancer.http_forwarding.name}"
  http_forwarding_port_range = local.load_balancer.http_forwarding.port_range
  http_forwarding_scheme     = local.load_balancer.http_forwarding.scheme

  http_proxy_name = "${terraform.workspace}--${local.load_balancer.http_proxy.name}"
  url_map_name    = "${terraform.workspace}--${local.load_balancer.url_map.name}"

  web_backend_service_name     = "${terraform.workspace}--${local.load_balancer.web_backend.name}"
  web_backend_service_protocol = local.load_balancer.web_backend.protocol
  web_backend_service_timeout  = local.load_balancer.web_backend.timeout

  http_health_check_name     = "${terraform.workspace}--${local.load_balancer.health_check.name}"
  http_health_check_interval = local.load_balancer.health_check.interval
  http_health_check_timeout  = local.load_balancer.health_check.timeout
  http_health_check_port     = local.load_balancer.health_check.port

}

module "profiles" {

  source                                      = "./modules/gcp/profiles"
  project_id                                  = var.gcp_project_id
  readonly_service_account_name               = "${terraform.workspace}--${local.policies.profiles.service.read_only.name}"
  cloud_function_service_account_name         = "${terraform.workspace}--${local.policies.profiles.cloud_function.read_only.name}"
  cloud_function_service_account_display_name = local.policies.profiles.cloud_function.read_only.caption

}

# https://console.cloud.google.com/apis/api/servicenetworking.googleapis.com/metrics?authuser=1&invt=AbtQvg&project=<gcp-project-id>
module "networking" {

  source         = "./modules/gcp/networking"
  region         = local.region
  gcp_project_id = var.gcp_project_id

  vpc_network_name  = "${terraform.workspace}--${local.networking.vpc_network_name}"
  subnet_name       = "${terraform.workspace}--${local.networking.subnet_name}"
  subnet_cidr_range = local.networking.subnet_cidr
  psa_range_name    = "${terraform.workspace}--${local.networking.psa_range_name}"
  psa_range_prefix  = local.networking.psa_range_prefix_length

  router_name = "${terraform.workspace}--${local.networking.nat.router_name}"
  nat_name    = "${terraform.workspace}--${local.networking.nat.config_name}"

  tcp_established_timeout_sec = local.networking.nat.timeouts.tcp_established_sec
  tcp_transitory_timeout_sec  = local.networking.nat.timeouts.tcp_transitory_sec
  udp_idle_timeout_sec        = local.networking.nat.timeouts.udp_idle_sec
  icmp_idle_timeout_sec       = local.networking.nat.timeouts.icmp_idle_sec

  enable_management_vpc               = local.services.networking.management.enable
  management_vpc_name                 = "${terraform.workspace}--${local.networking.management.vpc_name}"
  management_subnet_name              = "${terraform.workspace}--${local.networking.management.subnet_name}"
  management_subnet_cidr              = local.networking.management.subnet_cidr
  management_private_ip_google_access = local.networking.management.private_ip_google_access

}
