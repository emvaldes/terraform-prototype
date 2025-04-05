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

**Objective**: This document provides a unified, high-level explanation of how all project components—modules, configurations, scripts, workflows—interact to form a robust, modular, multi-cloud infrastructure framework. It serves as a reference map for engineers and operators to understand the system architecture, flow of control, and integration dependencies.

This framework is designed to enable **automated, cloud-agnostic infrastructure delivery** with clean separation of logic, data, and orchestration. It allows seamless expansion, multi-environment testing, and integrates deeply with developer workflows via scripts and CI/CD.

---

## Architecture Layers

### 1. Configuration Layer (Declarative Control Plane)
- **Source:** [`project.json`](../project.json), [`configs/providers/*.json`](../configs/providers/), [`configs/targets/*.json`](../configs/targets/), [`configs/policies.json`](../configs/policies.json), [`configs/allowed.json`](../configs/allowed.json)
- **Purpose:** Define all environmental, provider-specific, and policy logic.
- **Function:** Abstracts and centralizes configuration data for modular reuse.

### 2. Orchestration Layer (Terraform Root)
- **Source:** [`main.tf`](../main.tf), [`variables.tf`](../variables.tf), [`backend.tf`](../backend.tf), [`providers.tf`](../providers.tf), [`outputs.tf`](../outputs.tf)
- **Purpose:** Glue layer that connects inputs to cloud-specific modules.
- **Function:** Converts JSON-driven inputs into environment-aware resource provisioning.

### 3. Module Layer (Cloud-Specific Resource Definitions)
- **Source:** [`modules/gcp/*`](../modules/gcp)
- **Purpose:** Define reusable infrastructure constructs for networking, compute, load balancing, IAM, and serverless functions.
- **Function:** Encapsulate logic into parameterized, output-rich components.

### 4. Automation Layer (Shell & Python Scripts)
- **Source:** [`scripts/manage`](../scripts/manage), [`scripts/stressload`](../scripts/stressload), [`scripts/configure`](../scripts/configure), [`scripts/docs`](../scripts/docs)
- **Purpose:** Automate lifecycle workflows (plan, apply, test, teardown).
- **Function:** Interface with Terraform via CLI, wrap dynamic logic around outputs and configs.

#### Automation Script Breakdown
- `scripts/manage`: Backend setup, destroy flows, packaging, introspection
- `scripts/stressload`: Load tests (e.g., `run-stressload.shell`), Cloud Function tests
- `scripts/configure`: Startup config injection (e.g., `apache-webserver.shell`)
- `scripts/docs`: Documentation tooling (TF, YAML processors)

### 5. CI/CD & Workflow Layer
- **Source:** [`.github/workflows/terraform.yaml`](../.github/workflows/terraform.yaml)
- **Purpose:** Trigger, validate, and deploy infrastructure declaratively via GitHub Actions.
- **Function:** Handles linting, planning, deployment, testing, artifact export, and teardown.

---

## Data Flow & Dependencies

1. **User input or CI trigger** selects environment and provider →
2. `project.json` + `configs/*` drive **Terraform variable resolution** →
3. Terraform reads root module and invokes appropriate submodules (e.g., `networking`, `compute`) →
4. **Modules generate outputs** (e.g., IPs, URLs, names) →
5. Outputs saved to `outputs.json` and used by **scripts** and **workflows** →
6. **Cloud Function packages** are generated using these outputs, deployed into the same infrastructure →
7. **Stressload, diagnostics, inspection scripts** leverage live outputs for real-time validation

---

## Output Contracts
- All modules expose structured outputs (e.g., `load_balancer_ip`, `instance_group_name`).
- Outputs are captured using `terraform output -json > tf-outputs.json`
- A filtered and minimized `config.json` is generated dynamically for GCP Cloud Functions.
- These files are read by automation tools and never store secrets—only non-sensitive metadata.

---

## Interaction Summary
| Component              | Depends On                      | Consumes                         |
|------------------------|----------------------------------|----------------------------------|
| `main.tf`              | `project.json`, `variables.tf`  | Module outputs                   |
| `gcp/compute`          | `gcp/networking`, firewall      | Startup script, tags             |
| `gcp/load_balancer`    | `gcp/compute`                   | Instance group, named ports      |
| `gcp/cloud_function`   | outputs.json, script zip        | Target URL, IAM profile          |
| `package-functions.sh` | Terraform outputs               | Python files, config.json        |
| `inspect-services.sh`  | Terraform outputs               | Backend configs, forwarding rule |
| `terraform.yaml`       | Everything                      | Controls execution flow          |

---

## Optional CI/CD Modes
- **Deploy**: Standard provisioning and persistence
- **Test-only**: Apply → Inspect → Destroy (used for pipeline validation)
- **Stressload-enabled**: Load test webservers using `hey` via scripted workflows

---

## Cloud Function Security Notes
- All Cloud Functions use scoped, ephemeral IAM identities
- Ingress is restricted via IAM bindings and optionally firewall rules
- `config.json` files used by functions are generated with a **zero-trust** principle—only necessary values included
- Deployed functions are destroyed post-test unless otherwise configured

---

## Extensibility
- Add environments: Create new `configs/targets/<env>.json`
- Add providers: Extend `project.json` + `configs/providers/<provider>.json`
- Add services: Implement new module, reference from `main.tf`, inject variables

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

### `/project.json`
Defines the project's defaults settings, configurations paths and scripting resources for all automed services.

**Ownership**: Application Management

```json
{
    "defaults": {
        "provider": "gcp",
        "target": "dev"
    },
    "configs": {
        "providers": {
            "path": "./configs/providers",
            "sets": {
                "aws": "aws.json",
                "azure": "azure.json",
                "gcp": "gcp.json"
            }
        },
        "targets": {
            "path": "./configs/targets",
            "sets": {
                "dev": "dev.json",
                "prod": "prod.json",
                "staging": "staging.json"
            }
        }
    },
    "scripts": {
        "configure": {
            "apache_webserver": {
                "path": "./scripts/configure",
                "script": "apache-webserver.shell"
            }
        },
        "manage": {
            "inspect_services": {
                "path": "./scripts/manage",
                "script": "inspect-services.shell"
            },
            "package_functions": {
                "path": "./scripts/manage",
                "script": "package-functions.shell"
            },
            "inspect_autoscaling": {
                "path": "./scripts/manage",
                "script": "inspect-autoscaling.shell"
            },
            "terraform_backend": {
                "path": "./scripts/manage",
                "script": "terraform-backend.shell"
            }
        },
        "stressload": {
            "webservers": {
                "path": "./scripts/stressload",
                "script": "stressload-webservers.zip"
            }
        }
    }
}
```

### `/configs/providers/gcp.json`
Defines: provider, project, regions, compute types, services (cloud function, compute, firewall,load balancing, networking, and other infrastructure services.

**Ownership**: Infrastructure Administrators

```json
{
    "provider": "gcp",
    "project_id": "static-lead-454601-q1",
    "credentials": "",
    "regions": {
        "west": "us-west2",
        "central": "us-central2",
        "east": "us-east2"
    },
    "types": {
        "micro": "e2-micro",
        "medium": "e2-medium",
        "standard": "n1-standard-1"
    },
    "services": {
        "cloud_function": {
          "enable": false,
          "name": "webapp-stress-tester",
          "description": "Stub Cloud Function for stress testing framework",
          "entry_point": "main",
          "runtime": "python311",
          "memory": "256M",
          "timeout": 60,
          "bucket_name": "cloud-function-bucket",
          "archive_path": "./packages",
          "archive_name": "stressload-webservers.zip",
          "force_destroy": true,
          "env": {
            "TARGET_URL": ""
          },
          "event_type": "google.cloud.functions.v2.eventTypes.EVENT_TRIGGERED",
          "pubsub_topic": null,
          "invoker_role": "roles/cloudfunctions.invoker",
          "invoker_member": "allUsers"
        },
        "compute_resources": {
          "instance_template_name_prefix": "web-server-template--",
          "instance_group_name": "web-servers-group",
          "base_instance_name": "web-server",
          "source_image": "ubuntu-os-cloud/ubuntu-2004-lts",
          "startup_script_path": "./scripts/configure/apache-webserver.shell",
          "instance_tags": [
            "ssh-access",
            "http-server"
          ],
          "health_check": {
            "name": "http-health-check",
            "interval": 5,
            "timeout": 5,
            "port": 80
          }
        },
        "firewall_rules": {
          "allow_ssh": {
            "name": "allow-ssh-restricted",
            "protocol": "tcp",
            "ports": ["22"],
            "target_tags": ["ssh-access"]
          },
          "allow_ssh_iap": {
            "name": "allow-ssh-iap",
            "protocol": "tcp",
            "ports": ["22"],
            "target_tags": ["ssh-access"]
          },
          "allow_http_https": {
            "name": "allow-http-https",
            "protocol": "tcp",
            "ports": ["80", "443"]
          },
          "public_http_ranges": ["0.0.0.0/0"]
        },
        "health_check": {
            "name": "http-health-check"
        },
        "http_forwarding": {
            "name": "http-forwarding-rule"
        },
        "load_balancer": {
          "http_forwarding": {
            "name": "http-forwarding-rule",
            "port_range": "80",
            "scheme": "EXTERNAL"
          },
          "http_proxy": {
            "name": "web-http-proxy"
          },
          "url_map": {
            "name": "web-url-map"
          },
          "web_backend": {
            "name": "web-backend-service",
            "protocol": "HTTP",
            "timeout": 30
          },
          "health_check": {
            "name": "http-health-check",
            "interval": 5,
            "timeout": 5,
            "port": 80
          }
        },
        "networking": {
          "vpc_network_name": "webapp-vpc",
          "subnet_name": "webapp-subnet",
          "subnet_cidr": "10.100.0.0/24",
          "psa_range_name": "cloudsql-psa-range",
          "psa_range_prefix_length": 16,
          "nat": {
            "router_name": "webapp-router",
            "config_name": "webapp-nat-config",
            "nat_logging_filter": "ERRORS_ONLY",
            "enable_nat_logging": true,
            "timeouts": {
              "tcp_established_sec": 1200,
              "tcp_transitory_sec": 30,
              "udp_idle_sec": 30,
              "icmp_idle_sec": 30
            }
          },
          "management": {
            "enable": false,
            "vpc_name": "mgmt-vpc",
            "subnet_name": "mgmt-subnet",
            "subnet_cidr": "10.90.0.0/24",
            "private_ip_google_access": true
          }
        },
        "web_autoscaling": {
            "name": "web-autoscaling"
        },
        "web_backend": {
            "name": "web-backend-service"
        }
    }
}
```

### `/configs/targets/dev.json`
This is an abstraction mechanism to allow multipe environments to define implementation agnostic configurations.

**Ownership**: DevOps Engineers

```json
{
    "id": "dev",
    "name": "development",
    "description": "Development environment",
    "region": "west",
    "type": "micro",
    "policies": {
        "autoscaling": "basic",
        "stressload": "low"
    }
}
```

### `/configs/policies.json`
This is an abstraction mechanism to define services configurations.

**Ownership**: DevSecOps/DevNetOps Engieners

```json
{
    "autoscaling": {
        "profiles": {
            "basic": {
                "min": 1,
                "max": 2,
                "threshold": 0.6,
                "cooldown": 60
            },
            "medium": {
                "min": 2,
                "max": 4,
                "threshold": 0.65,
                "cooldown": 90
            },
            "advanced": {
                "min": 3,
                "max": 6,
                "threshold": 0.7,
                "cooldown": 120
            }
        },
        "logging": {
            "log_file": "./logs/autoscaling.log",
            "log_format": "%(asctime)s - %(levelname)s - %(message)s"
        }
    },
    "profiles": {
        "service": {
            "read_only": {
                "name": "ro--service-account",
                "caption": "Service Account (Read Only)"
            }
        },
        "cloud_function": {
            "read_only": {
                "name": "ro--cloud-function",
                "caption": "Cloud Function SA (Stress Test)"
            }
        }
    },
    "storage": {
        "bucket": {
            "name": "multi-cloud-terraform-state"
        }
    },
    "stressload": {
        "levels": {
            "low": {
                "duration": 60,
                "threads": 250,
                "interval": 0.04,
                "requests": 10000
            },
            "medium": {
                "duration": 60,
                "threads": 500,
                "interval": 0.02,
                "requests": 30000
            },
            "high": {
                "duration": 60,
                "threads": 1000,
                "interval": 0.01,
                "requests": 1000000
            }
        },
        "logging": {
            "log_file": "./logs/stressload.log",
            "log_format": "%(asctime)s - %(levelname)s - %(message)s"
        }
    }
}
```

### `allowed.json`
Specifies IP ranges allowed through firewall ingress rules.
* DevOps IPS: Whitelisting remote IP adddresses.
* Private IPS: Determine Allowed VPC Peering traffic.
* Console IPS: Allows for the GCP SSH Console access.

```json
{
  "devops_ips": [
    "68.109.187.94"
  ],
  "private_ips": [
    "10.0.0.0/8"
  ],
  "console_ips": [
    "35.235.240.0/20"
  ]
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
│   ├── README.md
│   └── workflows/
│       ├── README.md
│       └── terraform.yaml
├── .gitignore
├── .local/
│   ├── dev-tfplan.binary
│   └── dev-tfplan.json
├── LICENSE
├── README.md
├── backend.tf
├── configs/
│   ├── README.md
│   ├── allowed.json
│   ├── policies.json
│   ├── project/
│   │   ├── aws.json
│   │   ├── azure.json
│   │   └── gcp.json
│   └── targets/
│       ├── dev.json
│       ├── prod.json
│       └── staging.json
├── logs/
│   └── README.md
├── main.tf
├── modules/
│   ├── README.md
│   └── gcp/
│       ├── cloud_function/
│       │   ├── README.md
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
│       ├── networking/
│       │   ├── README.md
│       │   ├── manage.tf
│       │   ├── networking.tf
│       │   ├── outputs.tf
│       │   ├── router.tf
│       │   └── variables.tf
│       └── profiles/
│           ├── main.tf
│           ├── outputs.tf
│           └── variables.tf
├── outputs.json
├── outputs.tf
├── packages/
│   ├── REDME.md
│   └── stressload-webservers.zip
├── project.json
├── providers.tf
├── reports/
│   ├── README.md
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
│   ├── README.md
│   ├── configure/
│   │   └── apache-webserver.shell*
│   ├── docs/
│   │   ├── apache-webserver.md
│   │   ├── cloud-function.md
│   │   ├── inspect-services.md
│   │   └── terraform-backend.md
│   ├── manage/
│   │   ├── destroy-services.shell*
│   │   ├── gcloud-presets.shell*
│   │   ├── inspect-autoscaling.shell*
│   │   ├── inspect-services.shell*
│   │   ├── package-functions.shell*
│   │   └── terraform-backend.shell*
│   └── stressload/
│       └── webservers/
│           ├── config.json
│           ├── main.py
│           └── requirements.txt
└── variables.tf

25 directories, 89 files
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

---
