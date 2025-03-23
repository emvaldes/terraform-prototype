# File: /outputs.tf
# Version: 0.1.1

# --- Global Outputs ---

output "environment_config" {
  description = "The target workspace configuration loaded from targets JSON"
  value       = local.workspace
}

output "gcp_project_config" {
  description = "The full GCP-specific provider config from project JSON"
  value       = local.provider
}

output "project_id" {
  description = "The active GCP project ID"
  value       = local.project_id
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
  value       = local.cloud_function.enable ? module.cloud_function[0].function_name : null
}

output "cloud_function_url" {
  description = "The HTTPS trigger URL for the Cloud Function"
  value       = local.cloud_function.enable ? module.cloud_function[0].function_url : null
}

output "cloud_function_upload_target" {
  description = "Terraform target path for uploading the Cloud Function archive"
  value       = module.cloud_function[0].upload_target
}

output "cloud_function_region" {
  description = "Region where the Cloud Function is deployed"
  value       = local.cloud_function.enable ? module.cloud_function[0].function_region : null
}

output "cloud_function_bucket" {
  description = "The name of the bucket storing the Cloud Function source code"
  value       = local.cloud_function.enable ? module.cloud_function[0].function_bucket : null
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
  value       = local.cloud_function.enable ? module.cloud_function[0].stressload_config : null
  description = "Resolved stressload level config from module"
}

output "stressload_function_bucket" {
  value       = local.cloud_function.enable ? module.cloud_function[0].stressload_function_bucket : null
  description = "Bucket storing the stressload Cloud Function archive"
}

output "stressload_function_name" {
  value       = local.cloud_function.enable ? module.cloud_function[0].stressload_function_name : null
  description = "Name of the stressload Cloud Function (null if disabled)"
}

output "stressload_function_region" {
  value       = local.cloud_function.enable ? module.cloud_function[0].stressload_function_region : null
  description = "Region of the deployed stressload Cloud Function"
}

output "stressload_function_service_account_email" {
  value       = local.cloud_function.enable ? module.cloud_function[0].stressload_function_service_account_email : null
  description = "Service account email for the stressload Cloud Function"
}

output "stressload_key" {
  value       = local.cloud_function.enable ? module.cloud_function[0].stressload_key : null
  description = "Resolved stressload level key from module"
}

output "stressload_log_level" {
  value       = local.cloud_function.enable ? module.cloud_function[0].stressload_log_level : null
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

# --- Tagging Implementation Outputs ---

output "cloud_function_tags" {
  description = "Tags applied to the Cloud Function (if enabled)"
  value       = local.cloud_function.enable ? module.cloud_function[0].cloud_function_tags : null
}

output "compute_instance_tags" {
  description = "Tags applied to compute instances"
  value       = module.compute.instance_tags
}

output "firewall_allow_ssh_tags" {
  description = "Target tags for allow_ssh firewall rule"
  value       = module.firewall.allow_ssh_tags
}

output "firewall_allow_ssh_iap_tags" {
  description = "Target tags for allow_ssh_iap firewall rule"
  value       = module.firewall.allow_ssh_iap_tags
}

output "load_balancer_tags" {
  description = "Tags defined for the load balancer (not applied)"
  value       = module.load_balancer.load_balancer_tags
}

output "profiles_tags" {
  description = "Tags defined for service accounts in profiles module (not applied)"
  value       = module.profiles.profiles_tags
}

output "networking_tags" {
  description = "Tags applied to networking resources (only on supported ones)"
  value       = module.networking.networking_tags
}

# --- Storage Module Outputs ---

output "storage_bucket_iam_bindings" {
  description = "IAM role bindings applied to the Terraform state bucket"
  value       = module.storage.bucket_iam_bindings
}
