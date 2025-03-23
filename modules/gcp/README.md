# GCP Terraform Modules Documentation

This document provides comprehensive technical documentation for all Google Cloud Platform (GCP) Terraform modules used in this infrastructure framework. These modules encapsulate reusable, composable infrastructure logic and are structured to support environment-driven, cloud-agnostic automation.

---

## Module: `gcp/cloud_function/`

**Files:**
- `cloud_function.tf`
- `cloud_function.variables.tf`
- `cloud_function.outputs.tf`

### Purpose
Provisions a Google Cloud Function for lightweight, serverless, HTTP-triggered compute tasks. It is optimized for ephemeral utility functions, such as load testing agents or validation endpoints, that can be dynamically deployed and torn down.

### Inputs
- `function_name`, `runtime`, `entry_point`, `source_archive_bucket`
- `timeout`, `available_memory_mb`, `environment_variables`

### Outputs
- `url`, `name`, `service_account_email`

### Integration
- Source packaged via `scripts/manage/package-functions.shell`
- Invoked directly via GitHub workflows or CLI automation post-deployment

---

## Module: `gcp/networking/`

**Files:**
- `networking.tf`, `networking.manage.tf`, `networking.router.tf`
- `networking.variables.tf`, `networking.outputs.tf`

### Purpose
Defines the foundational network infrastructure for GCP, including VPCs, subnets, NAT, PSA, and routers.

### Inputs
- `vpc_name`, `region`, `cidr_blocks`, `enable_psa`, `nat_enabled`

### Outputs
- `vpc_self_link`, `subnet_name`, `nat_ip_list`, `router_name`

### Integration
- Required by all compute and function modules
- Sourced and configured dynamically via `project.json` and `configs/`

---

## Module: `gcp/firewall/`

**Files:**
- `firewall.tf`, `firewall.variables.tf`, `firewall.outputs.tf`

### Purpose
Implements secure ingress and egress firewall rules based on strict IP allowlisting and service port definitions. Ensures all ingress is restricted to known CIDRs defined in `configs/allowed.json`.

### Key Features
- Rule set generation for SSH, HTTP(S), ICMP, health checks
- Service-to-service internal allowlists

### Inputs
- `project_id`, `network`, `region`, `allowed_ssh_cidrs`, `allowed_http_cidrs`
- `internal_ranges`, `tag_selectors`, `log_config`

### Outputs
- `firewall_rule_ids`: IDs of provisioned rules
- `http_tags`, `ssh_tags`: Tags applied to instance templates

### Integration
- Relies on `allowed.json` and `targets/<env>.json` for policy enforcement
- Referenced by compute and ALB templates for tag-based access

---

## Module: `gcp/load_balancer/`

**Files:**
- `load_balancer.tf`, `load_balancer.variables.tf`, `load_balancer.outputs.tf`

### Purpose
Creates a fully managed HTTP(S) Global Load Balancer with backend autoscaling instance groups, URL maps, and health checks. Serves as the public entrypoint for the deployed web application or service.

### Components Provisioned
- URL map, target proxy, forwarding rule
- Backend service with health checks
- Instance group attachments via named ports

### Inputs
- `project_id`, `region`, `service_name`, `instance_group_name`
- `named_ports`, `backend_config`, `health_check_config`

### Outputs
- `load_balancer_ip`, `forwarding_rule_name`, `backend_service_name`

### Integration
- Tied to autoscaling compute resources from `compute/`
- Outputs are consumed in reports and test scripts
- Used by `scripts/stressload/webservers/main.py` as the primary target URL

---

## Module: `gcp/compute/`

**Files:**
- `compute.tf`, `compute.variables.tf`, `compute.outputs.tf`

### Purpose
Provisions managed instance templates and group managers for backend workloads. Supports autoscaling, load balancing, startup scripts, and custom machine images.

### Capabilities
- Launch templates with startup scripts
- Autoscaler with scale-in/out policies
- Network tags for firewall rule integration

### Inputs
- `project_id`, `region`, `instance_template_name`, `machine_type`
- `tags`, `startup_script`, `disk_config`, `autoscaler_config`

### Outputs
- `instance_group_name`, `template_self_link`, `autoscaler_id`

### Integration
- Attached to load balancer as backend service
- Network tags linked to `firewall/`
- Startup script may include Apache or app install steps via `scripts/configure/`

---

## Module: `gcp/profiles/`

**Files:**
- `profiles.tf`, `profiles.variables.tf`, `profiles.outputs.tf`

### Purpose
Captures metadata profiles for service accounts, users, or IAM identity bindings. Supports centralized access management and user-to-role mapping.

### Use Cases
- Defining custom roles
- Managing service account bindings
- Isolating cloud functions or backend components via IAM profiles

### Inputs
- `identity_list`, `roles`, `project_id`, `binding_targets`

### Outputs
- `iam_profile_bindings`, `service_account_names`

### Integration
- Used by cloud function and CI/CD workflows for access scoping
- Outputs feed into monitoring and audit trail generation

---

All modules are driven by centralized configuration defined in `project.json`, `configs/targets/`, and `configs/policies.json`, ensuring reusable logic and composability across environments and cloud providers.

This document will continue to evolve with usage examples and Terraform schema diagrams per module.

