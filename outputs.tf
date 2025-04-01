# File: /outputs.tf
# Version: 0.1.0

# --- Global Outputs ---

output "environment_config" {
  description = "The target workspace configuration loaded from targets JSON"
  value       = local.workspace
}

output "gcp_project_config" {
  description = "The full GCP-specific provider config from project JSON"
  value       = local.provider
}

output "gcp_project_id" {
  description = "The active GCP project ID"
  value       = var.gcp_project_id
}

output "region" {
  description = "The resolved GCP region for deployment"
  value       = local.region
}

output "workspace" {
  description = "The active Terraform workspace/environment"
  value       = terraform.workspace
}

# --- Cloud Function Module Outputs ---

output "cloud_function_name" {
  description = "The name of the deployed Cloud Function"
  value       = module.cloud_function.function_name
}

output "cloud_function_url" {
  description = "The HTTPS trigger URL for the Cloud Function"
  value       = module.cloud_function.function_url
}

output "cloud_function_region" {
  description = "Region where the Cloud Function is deployed"
  value       = module.cloud_function.function_region
}

output "cloud_function_bucket" {
  description = "The name of the bucket storing the Cloud Function source code"
  value       = module.cloud_function.function_bucket
}

output "cloud_function_service_account_email" {
  description = "The email of the Cloud Function service account"
  value       = module.profiles.cloud_function_service_account_email
}

output "cloud_function_service_account_unique_id" {
  description = "The unique ID of the Cloud Function service account"
  value       = module.profiles.cloud_function_service_account_unique_id
}

# --- Cloud Function - Stress Loading Outputs ---

output "stressload_config" {
  value       = module.cloud_function.stressload_config
  description = "Resolved stressload level config from module"
}

output "stressload_function_bucket" {
  value       = module.cloud_function.stressload_function_bucket
  description = "Bucket storing the stressload Cloud Function archive"
}

output "stressload_function_name" {
  value       = module.cloud_function.stressload_function_name
  description = "Cloud Function name for the stressload probe"
}

output "stressload_function_region" {
  value       = module.cloud_function.stressload_function_region
  description = "Region of the deployed stressload Cloud Function"
}

output "stressload_function_service_account_email" {
  value       = module.cloud_function.stressload_function_service_account_email
  description = "Service account email for the stressload Cloud Function"
}

output "stressload_key" {
  value       = module.cloud_function.stressload_key
  description = "Resolved stressload level key from module"
}

output "stressload_log_level" {
  value       = module.cloud_function.stressload_log_level
  description = "Log level used by stressload tooling"
}

# --- Compute Module Outputs ---

output "compute_instance_template" {
  description = "The self_link of the created instance template"
  value       = module.compute.instance_template
}

output "compute_instance_type" {
  description = "Instance type used in compute resources"
  value       = module.compute.instance_type
}

output "compute_web_autoscaler_name" {
  description = "Name of the compute autoscaler resource"
  value       = module.compute.web_autoscaler_name
}

output "compute_web_server_ip" {
  description = "Instance group URI used as web server backend"
  value       = module.compute.web_server_ip
}

output "compute_web_servers_group" {
  description = "Managed Instance Group for web servers"
  value       = module.compute.web_servers_group
}

# --- Firewall Module Outputs ---

output "firewall_console_ips" {
  description = "IP ranges allowed for Google Cloud Console (IAP)"
  value       = module.firewall.console_ips
}

output "firewall_devops_ips" {
  description = "IP ranges allowed for DevOps access"
  value       = module.firewall.devops_ips
}

output "firewall_private_ips" {
  description = "Private internal IP ranges allowed"
  value       = module.firewall.private_ips
}

output "firewall_public_http_ranges" {
  description = "CIDR ranges allowed for public HTTP/HTTPS traffic"
  value       = module.firewall.public_http_ranges
}

# --- Load Balancer Module Outputs ---

output "load_balancer_ip" {
  description = "The external IP address of the global HTTP(S) Load Balancer"
  value       = module.load_balancer.load_balancer_ip
}

output "http_forwarding_rule_name" {
  description = "Name of the global forwarding rule for HTTP traffic"
  value       = module.load_balancer.http_forwarding_rule_name
}

output "http_health_check_name" {
  description = "Name of the HTTP health check used by the backend service"
  value       = module.load_balancer.http_health_check_name
}

output "web_backend_service_name" {
  description = "Name of the backend service behind the load balancer"
  value       = module.load_balancer.web_backend_service_name
}

# --- Networking Module Outputs ---

output "cloudsql_psa_range_name" {
  description = "Name of the allocated Cloud SQL PSA range"
  value       = module.networking.cloudsql_psa_range_name
}

output "nat_name" {
  description = "Name of the Cloud NAT configuration"
  value       = module.networking.nat_name
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = module.networking.router_name
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = module.networking.subnet_id
}

output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = module.networking.vpc_network_id
}

# --- Networking Management VPC & Subnets ---

output "management_vpc_id" {
  description = "ID of the management VPC network"
  value       = module.networking.management_vpc_id
}

output "management_subnet_id" {
  description = "ID of the management subnet"
  value       = module.networking.management_subnet_id
}

output "management_subnet_cidr" {
  description = "CIDR range of the management subnet"
  value       = module.networking.management_subnet_cidr
}

# --- Profiles Module Outputs ---

output "readonly_service_account_email" {
  description = "Email address of the environment-specific read-only service account"
  value       = module.profiles.read_only_service_account_email
}

output "readonly_service_account_id" {
  description = "Unique ID of the environment-specific read-only service account"
  value       = module.profiles.read_only_service_account_unique_id
}
