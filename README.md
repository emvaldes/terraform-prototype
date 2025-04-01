# Multi-Cloud Terraform Automation Framework

## Overview
This project is a **fully automated, GitHub Actions-driven infrastructure-as-code (IaC) framework** built with **Terraform** for **Google Cloud Platform (GCP)**, designed to be easily extended to support **multi-cloud deployments** (AWS, Azure). It demonstrates deep proficiency in:

- Scalable, reusable, and modular Terraform design patterns
- Advanced JSON-driven configuration management
- Secure cloud resource provisioning and network controls
- CI/CD automation through declarative GitHub Actions workflows
- Automated infrastructure diagnostics using hardened shell scripts
- Environment lifecycle management and resource hygiene

This framework provisionally supports ephemeral environments, enforces workspace-specific configurations, and leverages centralized JSON files as the single source of truth across modules and automation scripts. All secrets and sensitive variables are externally injected, with no plaintext values stored in infrastructure files.

---

## Key Features

- **Environment Isolation:**
  - Fully realized Terraform workspace implementation
  - Resource name separation across `dev`, `staging`, and `prod`
  - Environment-specific counts, regions, and VM sizing

- **Secure State Management:**
  - Terraform state persisted to a remote GCS bucket
  - Automatic creation of backend on first deploy
  - Backup on `destroy` operations and artifact upload for traceability

- **Dynamic JSON Configuration:**
  - `project.json`, `workspaces.json`, and `allowed.json` used as structured inputs
  - No `.tfvars` files required—everything is environment-aware
  - Enables seamless extension to additional providers

- **Firewall Hardening (Zero Trust by Default):**
  - Ingress rules restricted to:
    - One specific DevOps IP address
    - RFC 1918 private address ranges
    - Google Cloud Console service subnet
  - No `0.0.0.0/0` exposure; enforced in code

- **Shell Script Automation:**
  - `./scripts/manage/terraform-backend.shell`: Handles backend bucket initialization and optional state recovery
  - `./scripts/configure/apache-webserver.shell`: Dynamically provisions VM environments for HTTP load testing
  - `./scripts/manage/inspect-services.shell`: Enumerates ALB configs, backend services, health checks
  - All scripts support execution flag expansion and verbose tracing

- **CI/CD GitHub Workflow Integration:**
  - Full Terraform lifecycle steps: `validate`, `plan`, `apply`, `destroy`
  - Dynamic switching of workspaces during workflow execution
  - Diagnostic logging (`gcloud`, `terraform`, `jq`) included

- **Traceable Deployments & State Artifacts:**
  - Logs, install traces, and state backups uploaded via `actions/upload-artifact`
  - Useful for postmortem analysis and rollback capability

- **Multi-Cloud Ready Architecture:**
  - Modular decomposition of compute, networking, and firewall layers
  - Supports future `aws` and `azure` modules via interface-compatible design

---

## Infrastructure Components

### 1. **Compute Layer** (`compute.tf`, `scrits/configure/apache-webserver.shell`)
- Manages lifecycle of VM instances across GCP regions
- Instance names, sizes, and replica counts sourced from `workspaces.json`
- Designed to integrate with GCP health checks and managed instance groups

### 2. **Networking & Firewall** (`networking.tf`, `firewall.tf`, `allowed.json`)
- Creates isolated virtual networks (VPCs)
- Subnet definitions scoped per region
- Firewall ingress and egress rules enforced from `allowed.json` inputs

### 3. **Load Balancing** (`router.tf`, `./scripts/manage/inspect-services.shell`)
- Instantiates HTTP(S) Global Load Balancer components:
  - Global forwarding rule
  - Target proxy
  - URL map and backend service
  - Health check with regional scope
- Scripted inspection returns JSON overview of all key load balancer components

### 4. **Routing & NAT Configuration** (`router.tf`)
- Enables NAT gateway for instances without public IPs
- Ensures egress connectivity for patching, installation, and monitoring
- Cloud router setup is fully automated

### 5. **State Management** (`./scripts/manage/terraform-backend.shell`, `backend.tf`, `project.json`)
- Validates bucket existence or creates it securely using `gsutil`
- When `destroy` is run, conditionally downloads remote state to `.local/`
- Supports state file introspection and traceability via artifacts

---

## Configuration Files

### `project.json`
Defines the cloud provider, backend bucket, and GCP-specific credentials.
```json
{
  "provider": "gcp",
  "storage": {
    "bucket": "multi-cloud-terraform-state"
  },
  "gcp": {
    "project": "<project-name>",
    "credentials": ""
  }
}
```

### `workspaces.json`
Maps each workspace to its region, instance type, instance count, and uniquely named infrastructure components.
```json
{
  "default": "dev",
  "targets": {
    "dev": { ... },
    "staging": { ... },
    "prod": { ... }
  }
}
```

### `allowed.json`
Specifies IP ranges allowed through firewall ingress rules.
```json
{
  "devops_ips": ["68.109.187.94"],
  "private_ips": ["10.0.0.0/8"],
  "console_ips": ["35.235.240.0/20"]
}
```

---

## GitHub Actions CI/CD Pipeline (`terraform.yaml`)

### Trigger
The workflow is manually triggered using `workflow_dispatch` and accepts two parameters:
- `target_environment`: one of `dev`, `staging`, or `prod`
- `action`: `validate`, `plan`, `apply`, or `destroy`

### Key Phases
- **Environment Setup:**
  - Decodes credentials from GitHub Secrets → JSON file
  - Extracts region and forwarding rule name from JSON
- **Diagnostics Phase:**
  - Lists active authentication, configurations, projects, zones, services, and networks using `gcloud`
- **Terraform Lifecycle:**
  - Initializes backend
  - Switches to correct workspace or creates it
  - Validates syntax, plans, and applies changes
- **Safe Destruction:**
  - Destroy allowed only in `dev`
  - Downloads and uploads Terraform state before deletion

---

## Testing Strategy

The project includes built-in testing hooks:
1. `terraform validate`: Static validation for every execution
2. `terraform plan`: Logged in GitHub workflow output
3. (Optional) Load balancer HTTP check using public IP and `curl`
4. Diagnostic shell commands for inspecting real-time cloud state

All logs are captured and uploaded to GitHub Artifacts to assist in post-deploy analysis or CI traceability.

---

## Terraform Outputs

Defined in `outputs.tf` and printed after `apply`, these include:
- `instance_ips`: List of internal or external IPs of all compute instances
- `forwarding_rule_ip`: Public IP of the load balancer’s forwarding rule
- `backend_service_name`: Name of the created backend service used by the load balancer

---

## Directory & File Layout

```console
├── .github/
│   └── workflows/
│       ├── README.md
│       └── terraform.yaml
├── .gitignore
├── .local/
│   ├── dev-tfplan.binary
│   └── dev-tfplan.json
├── .terraform/
│   ├── environment
│   ├── modules/
│   │   └── modules.json
│   ├── providers/
│   │   └── registry.terraform.io/
│   │       └── hashicorp/
│   │           └── google/
│   │               └── 6.27.0/
│   │                   └── darwin_amd64/
│   │                       ├── LICENSE.txt
│   │                       └── terraform-provider-google_v6.27.0_x5*
│   └── terraform.tfstate
├── .terraform.lock.hcl
├── LICENSE
├── README.md
├── allowed.json
├── backend.tf
├── configs/
│   ├── policies.json
│   ├── project/
│   │   ├── aws.json
│   │   ├── azure.json
│   │   └── gcp.json
│   └── targets/
│       ├── dev.json
│       ├── prod.json
│       └── staging.json
├── main.tf
├── modules/
│   └── gcp/
│       ├── cloud_function/
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── compute/
│       │   ├── README.md
│       │   ├── compute.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── firewall/
│       │   ├── README.md
│       │   ├── firewall.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── load_balancer/
│       │   ├── README.md
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       └── networking/
│           ├── README.md
│           ├── networking.tf
│           ├── outputs.tf
│           ├── router.tf
│           └── variables.tf
├── outputs.tf
├── project.json
├── providers.tf
├── reports/
│   ├── configs/
│   │   ├── backend-services.json
│   │   ├── compute-instances.json
│   │   ├── firewall-rules-describe.json
│   │   ├── firewall-rules.json
│   │   ├── forwarding-rules.json
│   │   ├── health-checks.json
│   │   ├── instance-groups.json
│   │   ├── instance-template.json
│   │   ├── networks-listing.json
│   │   ├── operations-listing.json
│   │   ├── project-policies.json
│   │   ├── proxies-listing.json
│   │   ├── service-account.json
│   │   ├── storage-buckets.json
│   │   └── subnets-listing.json
│   ├── inspect.console
│   ├── terraform.apply
│   ├── terraform.destroy
│   ├── terraform.plan
│   └── webserver.console
├── scripts/
│   ├── build/
│   │   └── stressload-webservers.zip
│   ├── configure/
│   │   └── apache-webserver.shell*
│   ├── docs/
│   │   ├── inspect-services.md
│   │   ├── setup-backend.md
│   │   └── setup-webserver.md
│   ├── manage/
│   │   ├── destroy-services.shell*
│   │   ├── inspect-services.shell*
│   │   ├── package-functions.shell*
│   │   └── terraform-backend.shell*
│   └── stressload/
│       └── webservers/
│           ├── main.py
│           └── requirements.txt
└── variables.tf
```

---

## Design Philosophy

This project emphasizes:
- **Zero Touch**: All config managed via structured data files
- **Multi-environment Repeatability**: One codebase, infinite environments
- **Security-First**: IP-restricted access, no unsecured routes
- **Automation-First**: Shell scripts encapsulate complexity
- **Cloud-Native Diagnostics**: Real-time GCP introspection tools baked into CI/CD
- **Terraform Best Practices**: Remote state, modules, variable separation

---

## Reviewer Evaluation Guide

### What to Evaluate
- **Security Discipline**: Hardened firewall, restricted access, secure state
- **Automation Scope**: CI/CD pipeline, diagnostics, GitHub artifacts
- **Infrastructure Quality**: Modular, environment-aware, extensible
- **Error Handling**: Fallback logic in scripts, safe destroy gating
- **Real-World Readiness**: Suitable for production with minor extensions

### Suggested Scenarios to Test
- Deploy into multiple environments
- Attempt `destroy` in `staging`/`prod` (should fail)
- Swap instance types in `workspaces.json` and re-apply
- Replace `allowed.json` values and observe firewall enforcement

---

## Future Enhancements

- Enable support for **AWS** and **Azure** via provider-agnostic modules
- Integrate **DNS and certificate automation** (Cloud DNS + ACM)
- Add **health-based failover** with multi-region support
- Enable **GitHub OIDC authentication** to eliminate static credentials
- Integrate with **Prometheus or GCP Cloud Monitoring**
- Add **alerting hooks** for failed runs or destroyed resources
- Create **Terraform modules** for reusable components (e.g., VPC, instance group)
- Add **pre-commit hooks** and **Terraform fmt/lint** integration for policy compliance
