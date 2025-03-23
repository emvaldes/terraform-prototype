# Multi-Cloud Terraform Automation Framework

[![Terraform GCP CI/CD Pipeline](https://github.com/emvaldes/terraform-prototype/actions/workflows/terraform.yaml/badge.svg)](https://github.com/emvaldes/terraform-prototype/actions/workflows/terraform.yaml)

## Overview

This project is a **fully automated, GitHub Actions-driven infrastructure-as-code (IaC) framework** built with **Terraform** for **Google Cloud Platform (GCP)**, designed to be easily extended to support **multi-cloud deployments** (AWS, Azure). It demonstrates deep proficiency in:

- Scalable, reusable, and modular Terraform design patterns
- Advanced JSON-driven configuration management
- Secure cloud resource provisioning and network controls
- CI/CD automation through declarative GitHub Actions workflows
- Automated infrastructure diagnostics using hardened shell scripts
- Environment lifecycle management and resource hygiene

This system automates the provisioning and management of cloud infrastructure on **Google Cloud Platform (GCP)** using **Terraform modules**, **Bash automation scripts**, and a suite of centralized **JSON configuration files**. It is **modular**, **policy-driven**, and designed to be **safe**, **repeatable**, and **fully inspectable**.

The framework supports **ephemeral, per-environment deployments** (e.g., `dev`, `staging`, `prod`) by enforcing **workspace-specific configurations** and dynamically wiring resources based on a declarative JSON model. All configuration values—such as instance types, scaling policies, service mappings, and RBAC settings—are loaded from structured inputs, making the system environment-agnostic and easy to extend.

Sensitive data and secrets are **never hardcoded**; they are **injected externally** via secure channels, ensuring compliance with best practices. The system emphasizes **traceability** through tagging, **visibility** through inspection scripts, and **control** through scoped policy definitions, enabling teams to manage infrastructure confidently and securely across all lifecycle phases.

---

**Objective**: This document provides a unified, high-level explanation of how all project components—modules, configurations, scripts, workflows—interact to form a robust, modular, multi-cloud infrastructure framework. It serves as a reference map for engineers and operators to understand the system architecture, flow of control, and integration dependencies.

This framework is designed to enable **automated, cloud-agnostic infrastructure delivery** with clean separation of logic, data, and orchestration. It allows seamless expansion, multi-environment testing, and integrates deeply with developer workflows via scripts and CI/CD.

---

## Architecture Layers

This section describes the layered structure of the automation framework. Each layer encapsulates a role in defining, orchestrating, provisioning, or validating cloud infrastructure on GCP.

---

### 1. **Configuration Layer – Declarative Control Plane**

- **Source:**
  [`project.json`](../project.json),
  [`configs/providers/*.json`](../configs/providers/),
  [`configs/targets/*.json`](../configs/targets/),
  [`configs/policies.json`](../configs/policies.json),
  [`configs/allowed.json`](../configs/allowed.json),
  [`configs/services/gcp/*.json`](../configs/services/gcp/)

- **Purpose:**
  Central source of truth for environment settings, regional constraints, resource counts, tagging, IAM policies, service mappings, RBAC rules, and access control.

- **Function:**
  These JSON files eliminate the need for `.tfvars` or hardcoded values. The Terraform root module dynamically pulls from these files using locals and conditionals, enabling environment-aware behavior without modifying `.tf` code.

---

### 2. **Orchestration Layer – Terraform Root Engine**

- **Source:**
  [`main.tf`](../main.tf), [`variables.tf`](../variables.tf), [`backend.tf`](../backend.tf), [`providers.tf`](../providers.tf), [`outputs.tf`](../outputs.tf)

- **Purpose:**
  Bridges configuration files to reusable modules. Injects environment-specific values into Terraform using dynamically computed locals.

- **Function:**
  Each `terraform apply` run loads all JSON configurations, sets the active workspace, and conditionally provisions modules such as compute, storage, IAM, load balancer, and cloud functions depending on `enabled` flags in `project.json` or `policies.json`.

---

### 3. **Module Layer – Infrastructure Constructs**

- **Source:**
  [`modules/gcp/*`](../modules/gcp/)

- **Modules:**
  - `compute`: VM instances and managed instance groups
  - `networking`: VPCs, subnets, routers, NATs
  - `firewall`: Ingress/egress rules defined in `allowed.json`
  - `load_balancer`: HTTP(S) global load balancer stack
  - `cloud_function`: Serverless workloads packaged via automation
  - `profiles`: IAM identity definitions and service account provisioning
  - `storage`: GCS buckets for Terraform state and other services

- **Function:**
  These are reusable, input-driven Terraform modules designed to emit rich outputs for inspection, diagnostics, and downstream use. Modules read only from parsed `locals`, not `var.*`.

---

### 4. **Automation Layer – Shell & Python Control Scripts**

- **Source:**
  [`scripts/manage/`](../scripts/manage), [`scripts/configure/`](../scripts/configure), [`scripts/stressload/`](../scripts/stressload), [`scripts/docs/`](../scripts/docs)

- **Purpose:**
  Provides lifecycle tooling, backend management, inspection interfaces, destruction routines, packaging flows, and integration with `terraform output`.

- **Key Scripts Overview:**

| Script                       | Responsibility                                                   |
|------------------------------|------------------------------------------------------------------|
| `configure-backend.shell`    | Create/download/destroy Terraform state buckets                  |
| `configure-profiles.shell`   | Create/delete IAM service accounts and credentials               |
| `configure-terraform.shelll` | Initialize Terraform and modules with custom backends            |
| `configure-workspaces.shell` | Constructs all worspaces and activates target workspace          |
| `inspect-services.shell`     | Full inspection of load balancer (IP, proxies, backends, health) |
| `inspect-autoscaling.shell`  | Stress testing with `hey`; measures autoscaler behavior          |
| `package-functions.shell`    | Zips and deploys Python Cloud Function using outputs             |
| `destroy-services.shell`     | Controlled teardown of GCP stack in dependency order             |
| `apache-webserver.shell`     | Instance startup script for VM webservers                        |
| `docs/*.md`                  | Human-readable documentation helpers                             |

---

### 5. **CI/CD Layer – GitHub Actions Integration**

- **Source:**
  [`.github/workflows/terraform.yaml`](../.github/workflows/terraform.yaml)

- **Purpose:**
  Enforces automation pipelines that apply, inspect, validate, and teardown infrastructure with full GitHub Actions support.

- **Function:**
  Environment-specific workflows validate plans, apply infrastructure conditionally, export outputs to artifacts, and invoke post-deploy scripts such as stress tests.

---

## Data Flow & Evaluation Sequence

```text
1. GitHub Actions or user CLI triggers Terraform plan/apply
2. Active workspace selected (e.g., dev, staging, prod)
3. Configuration JSONs loaded: project, policies, targets, allowed
4. Terraform root composes locals → passes values to modules
5. Modules provision infrastructure → emit structured outputs
6. Outputs saved to outputs.json → consumed by scripts
7. Scripts handle post-deploy tasks: packaging, deployment, inspection
```

---

## Terraform Outputs

- Each module defines standard Terraform outputs.
- `terraform output -json` is saved to `outputs.json` post-deploy.
- Scripts use this file to extract IPs, names, URLs, IAM identities.
- A reduced `config.json` is generated for Cloud Function payloads.
- Secrets are never stored; output files contain metadata only.

---

## Interaction Summary

| Component                  | Depends On                    | Consumes                       |
|----------------------------|-------------------------------|--------------------------------|
| `main.tf`                  | `project.json`, `locals.tf`   | Terraform modules              |
| `modules/gcp/*`            | locals, conditionals          | JSON configs                   |
| `compute`                  | `networking`, `firewall`      | Startup scripts, zones         |
| `load_balancer`            | `compute`                     | MIGs, named ports              |
| `cloud_function`           | outputs.json, archive.zip     | Target IP, IAM account         |
| `package-functions.shell`  | outputs.json                  | Python zip + config.json       |
| `inspect-services.shell`   | outputs.json                  | GCP service inspection         |
| `terraform.yaml`           | All layers                    | Full lifecycle orchestration   |

---

## Optional CI/CD Modes

- **Standard Deploy:** Full provision of infrastructure
- **Test-only Mode:** Create → Run `inspect-services` → Auto-teardown
- **Stress Test Mode:** Uses `inspect-autoscaling.shell` to verify scale-up/down
- **Artifact Mode:** Outputs archived via `terraform output` and ZIP bundles

---

## Cloud Function Security

- Cloud Functions use ephemeral service accounts with scoped permissions
- `config.json` contains only non-sensitive keys required by the function
- Bucket uploads are temporary unless flagged for persistence
- All functions can be auto-destroyed after test workflows

---

## Extensibility

| Task                   | How to Extend                                                             |
|------------------------|---------------------------------------------------------------------------|
| Add environment        | Add new file in `configs/targets/*.json`                                  |
| Add cloud provider     | Update `project.json`, add to `configs/providers/*.json`                  |
| Add new service/module | Add new Terraform module, reference from `main.tf`, create JSON interface |
| Add CI/CD logic        | Extend GitHub workflow or shell wrapper                                   |

---

## Key Features

### Environment Isolation
- Workspaces: `dev`, `staging`, `prod`
- Per-environment resource naming and counts
- No shared global resources unless explicitly scoped

### Secure State Management
- GCS-backed remote state with backend validation
- Bucket created dynamically per workspace
- `.tfstate` downloaded on `--delete` operations for audit trace

### JSON-Driven Input Model
- Eliminates `*.tfvars` and hardcoding
- Everything driven by environment JSONs
- Inputs parsed into Terraform locals for full reusability

### Zero Trust Firewall Defaults
- No public internet by default (`0.0.0.0/0` blocked)
- DevOps IP, Google Console subnet, and private ranges allowed
- Controlled entirely via `allowed.json`

### Full Lifecycle Automation
- Scripts manage backend, inspection, teardown, and packaging
- Terraform outputs inform scripts dynamically
- Inspection tooling validates configuration correctness post-deploy

---

### 🔧 Shell Script Automation

The following scripts are used to automate and standardize infrastructure tasks across GCP environments. Each script supports modular argument parsing, dry-run support, and optional verbose/debug tracing.

#### `./scripts/configure/apache-webserver.shell`
Automates the provisioning of compute VM instances configured to simulate HTTP traffic under various network load conditions.

- Dynamically deploys GCP compute instances using pre-defined profiles.
- Designed for benchmarking, load testing, or validating autoscaling policies.
- Config-driven: aligns with defined environment parameters and VM sizing.
- Automatically applies network tagging, firewall rules, and metadata configs.

#### `./scripts/manage/configure-backend.shell`
Handles the provisioning, inspection, download, and destruction of the Terraform remote state backend hosted on GCS, based on environment-targeted and JSON-driven configurations.

- Supports operations: `--list`, `--create`, `--download`, `--destroy`
- Applies GCS bucket naming patterns using `<env>--<purpose>--<project_id>`
- Automatically detects GCP project ID and region to resolve bucket location
- Downloads .tfstate files per workspace and converts them to .json using terraform show
- Reads configuration from project.json and configs/policies.json with optional overrides
- Performs safe and confirmed deletion with pre-download of all state files
- Creates .local/ directory for inspected/downloaded state snapshots
- Fully compatible with multi-workspace Terraform environments

#### `./scripts/manage/configure-profiles.shell`
Manages the creation and deletion of GCP IAM Service Accounts and credentials defined in a centralized profiles.json configuration.

- Supports operations: `--create`, `--delete`
- Automates service account creation, key generation, and credential cleanup
- Reads account metadata (name, description, filename) from `./configs/profiles.json`
- Derives full email and key paths based on active GCP project context
- Safely handles overwrites, prompting confirmation before credential deletion
- Outputs consistent and readable information about each account
- Ensures service account presence before performing key actions
- Requires gcloud and jq for GCP and JSON handling
- Fully idempotent and safe to re-run with dry-run and verbose modes

#### `./scripts/manage/configure-terraform.shell`
Bootstraps and orchestrates Terraform initialization, validation, and plan execution across multiple provider targets and workspaces using JSON-defined project context.

- Dynamically sets Terraform working directory and provider configuration
- Reads `project.json`, `configs/providers/*.json`, and `configs/targets/*.json`
- Supports operations: `--init`, `--plan`, `--show`, `--validate`, `--refresh`
- Handles workspace creation and selection automatically
- Applies external variables like `TF_VAR_*` and backend settings per workspace
- Provides clear formatted output logs for each phase
- Supports GCP authentication and regional targeting using environment variables
- Uses safe default fallback paths and Terraform automation flags

#### `./scripts/manage/configure-workspaces.shell`
Manages Terraform workspace lifecycle actions such as creation, listing, selection, and deletion in alignment with JSON-based configuration sets.

- Supports operations: `--list`, `--create`, `--select`, `--delete`
- Retrieves workspace names from `configs/targets/*.json` or `project.json`
- Can perform bulk creation or deletion across all configured workspaces
- Automates workspace initialization with minimal Terraform CLI assumptions
- Provides descriptive logging of active, new, or missing workspaces
- Detects backend availability and validates initialization context
- Ensures idempotent operations with fallback safety checks

#### `./scripts/manage/inspect-autoscaling.shell`
Performs a configurable stress test against a GCP HTTP Load Balancer and inspects autoscaling behavior of the associated Managed Instance Group (MIG).

- Executes multi-phase load testing (burst, sustained, cooldown, recovery) using hey
- Reads stress level and autoscaling profiles from centralized JSON configuration files
- Resolves MIG name, region, and target from Terraform outputs
- Captures real-time instance counts and lists active VMs per test phase
- Supports dynamic adjustment of thread concurrency, duration, and request intervals
- Validates existence of target and policy configs before execution
- Optional logic to reset MIG size (disabled when autoscaler is active)
- Outputs clear logs for each phase, instance state, and scaling response

#### `./scripts/manage/inspect-services.shell`
Inspects GCP infrastructure health, IAM configurations, and load balancer components in real-time using live gcloud, curl, and jq calls.

- Validates and traces HTTP Load Balancer components: forwarding rules, proxies, URL maps, and backend services
- Checks health checks, instance group membership, and autoscaler configuration
- Evaluates IAM bindings, roles, keys, and custom role usage across Terraform-managed identities
- Compares Terraform IAM outputs with current GCP policies to detect drift
- Scans for expiring IAM keys and misconfigured roles or unbound identities
- Fetches recent activity logs for IAM identities and autoscaling events
- Supports environment detection via Terraform or override variables
- Outputs all results as formatted JSON with sectioned summaries and key exports

#### `./scripts/manage/package-functions.shell`
Builds and prepares a Python-based Cloud Function package, extracting dynamic configuration from Terraform outputs and uploading artifacts to a target GCS bucket.

- Parses Terraform output and policies.json to construct environment-aware config files
- Dynamically injects autoscaling and stressload settings into config.json
- Packages source files and dependencies into a .zip archive for Cloud Function deployment
- Verifies required project ID, function name, region, and service account details
- Uploads the final archive to a pre-defined GCS bucket used by Terraform deployment
- Optionally triggers Terraform -target apply to complete archive upload without full plan
- Supports inspection of GCS object metadata, bucket size, and content listing after upload

---

#### `./scripts/others/destroy-services.shell`
Tears down all GCP resources related to a web application deployment in a controlled and dependency-aware sequence.<br />
It handles network, compute, and routing teardown with minimal interaction.

- Deletes HTTP Load Balancer components: forwarding rules, proxies, URL maps, backend services, and health checks
- Removes compute resources including MIGs, autoscalers, instance templates, and firewall rules
- Destroys networking components: NAT configs, routers, subnets, VPCs, and VPC peering ranges
- Requires project ID and region via --project-id and --region flags or fallback to gcloud/env
- Validates required inputs before execution to prevent accidental deletions
- All operations are fully non-interactive (--quiet) for automation use

#### `./scripts/others/gcloud-presets.shell`
Bootstraps and enforces consistent gcloud CLI environment settings across all systems.

- Applies default region, zone, and active account/project.
- Loads secure credentials and activates service accounts from managed config.
- Helps normalize local, CI/CD, or ephemeral environments before infrastructure interaction.

### Shared Features

- **Standardized Execution Flags**
  All scripts support modular CLI flags for consistent usage:
  `--create`, `--list`, `--delete`, etc.

- **Optional Modes for Safe Execution**
  Enable enhanced control with:
  `--dry-run`, `--verbose`, `--debug`

- **Config-Driven Behavior**
  Automatically loads input from:
  `project.json`, `policies.json`, or user-defined paths

- **Safe and Predictable Operations**
  Scripts are non-destructive by default, requiring explicit confirmation for deletions or changes

- **Readable and Traceable Output**
  Error messages are clean, informative, and optimized for debugging and automation logs

---

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

#### 1. **Compute Layer**

**Files:** `modules/gcp/compute/`, `scripts/configure/apache-webserver.shell`, `configs/services/gcp/compute_resources.json`
- Provisions GCE instances using custom instance templates and managed instance groups (MIGs)
- Instance types, replica counts, and metadata are sourced dynamically via `dev.json`, `policies.json`, and `compute_resources.json`
- Tagged using centralized `tagging.json` for traceability (e.g., `ssh-access`, `http-server`)
- Fully compatible with autoscaler modules and integrated health checks
- Web server initialization handled by a custom Apache setup script

#### 2. **Networking & Firewall**

**Files:** `modules/gcp/networking/`, `modules/gcp/firewall/`, `configs/allowed.json`, `tagging.json`
- Defines isolated, per-environment VPCs with regional subnets
- Establishes DNS resolution, IP ranges, NAT routing, and reserved PSA ranges
- Ingress/egress rules enforced using allowlists from `allowed.json` (e.g., `allow-ssh-restricted`, `allow-http-https`)
- Tags applied conditionally to firewall rules (e.g., `ssh-access`) for role-based enforcement
- Network components are automatically wired to Load Balancer backends and MIGs

#### 3. **Load Balancing**

**Files:** `modules/gcp/load_balancer/`, `scripts/manage/inspect-services.shell`, `configs/services/gcp/load_balancer.json`, `http_forwarding.json`, `web_backend.json`
- Implements a Global HTTP(S) Load Balancer stack with end-to-end Terraform automation
  - Global forwarding rules
  - Target HTTP proxies
  - URL maps (with default service bindings)
  - Regional backend service with health checks and autoscaling support
- `inspect-services.shell` provides live introspection of all components, including forwarding IPs, MIG health, proxy mappings, and instance group state

#### 4. **Routing & NAT Configuration**

**Files:** `modules/gcp/networking.router.tf`, `router.tf`, `configs/services/gcp/networking.json`
- Provisions GCP Cloud Routers and regional NAT gateways for internet access without public IPs
- Enables outbound traffic for instance patching, telemetry, and package installation
- NAT gateway configuration is driven by Terraform variables and policies for full reproducibility
- VPC peering and PSA allocation handled via automation scripts and `vpc-peerings` inspection

#### 5. **State Management**

**Files:** `backend.tf`, `scripts/manage/configure-backend.shell`, `project.json`, `policies.json`
- Manages remote Terraform state in GCS using a dynamic, workspace-prefixed bucket naming convention
- `configure-backend.shell` performs bucket creation, validation, state download, and `.tfstate` to `.json` transformation
- State files can be inspected under `.local/` during teardown or troubleshooting
- Supports RBAC-controlled provisioning based on `policies.json`, only creating backend resources when enabled
- Safe to re-run, fully idempotent, and supports dry-run/verbose modes

#### 6. **Storage & Bucket Provisioning**

**Files:** `modules/gcp/storage/`, `backend.tf`, `configs/policies.json`, `tagging.json`
- Creates GCS buckets conditionally based on environment-level policies defined in `policies.json`
- Bucket naming follows the convention: `<env>--<bucket-name>--<project_id>`
- Supports optional RBAC-based IAM binding if enabled via `storage.bucket.rbac`
- Retention policies, versioning, and access controls are defined through centralized JSON and applied through Terraform
- Tagging standards from `tagging.json` are applied to ensure service-level traceability (`storage`, `service-accounts`)
- Used by both backend state and Cloud Function deployments (via upload targets and artifact storage)

#### 7. **Terraform Setup & Workspace Automation**

**Files:** `scripts/manage/configure-terraform.shell`, `scripts/manage/configure-workspaces.shell`, `project.json`, `configs/providers/*.json`, `configs/targets/*.json`

- `configure-terraform.shell` prepares Terraform for execution by setting up CLI paths, validating tool presence, selecting the correct provider, and exporting relevant environment variables dynamically
- `configure-workspaces.shell` manages Terraform workspaces across environments (`dev`, `staging`, `prod`), supporting creation, selection, deletion, and inspection
- Both scripts are driven by JSON inputs and detect settings like project ID, region, provider type, and environment name automatically
- Ensures consistency and pre-validation before running any Terraform operations
- Designed for CI/CD pipelines and repeatable local runs
- Fully idempotent, supports dry-run/verbose/debug flags, and avoids redundant actions when workspace or CLI context is already valid

---

## 1. Configuration: The Source of Truth

Before any cloud resource is created, this system **loads configuration from JSON files**.
These configurations live in the `configs/` folder:

- **`project.json`**
  Defines which environment (like `dev`, `prod`, or `staging`) is being targeted, and where to find provider-specific configuration files.

- **`configs/providers/gcp.json`**
  Contains details about the GCP provider (such as regions, credentials, or defaults).

- **`configs/targets/dev.json`**
  Contains all environment-specific overrides—such as compute instance sizes or stress testing levels for the development environment.

- **`configs/policies.json`**
  Controls which features are turned on or off. For example:
  - Should storage buckets be created?
  - Should access controls (RBAC) be applied?

- **`configs/allowed.json`**
  Lists allowed firewall rules, like what IP ranges can SSH or connect via HTTP.

These JSON files are used instead of hardcoding variables, making the system easy to reuse across environments.

---

## 2. Terraform: Infrastructure as Code

Terraform is the core tool that **turns configuration into actual GCP resources**. It reads `.tf` files (like `compute.tf`, `networking.tf`, etc.) and provisions real infrastructure in GCP.
Terraform modules are organized like this:

```
modules/gcp/
├── compute/
├── storage/
├── firewall/
├── networking/
├── load_balancer/
├── cloud_function/
├── profiles/
```

Each module handles one part of the cloud environment.

- Before Terraform runs, the `scripts/manage/configure-terraform.shell` script ensures the CLI, environment variables, and provider paths are set up correctly. It validates tools, exports config values, and makes the environment Terraform-ready.

---

## 3. Modules and What They Do

### Compute (`modules/gcp/compute`)
- Provisions **virtual machines** (VMs) in GCP.
- Uses **managed instance groups (MIGs)** so Google can scale up or down based on demand.
- All configuration (how many VMs, what type, etc.) is pulled from `dev.json`, `compute_resources.json`, and `policies.json`.
- VM startup scripts are managed by `scripts/configure/apache-webserver.shell`.

---

### Networking & Firewall (`modules/gcp/networking`, `modules/gcp/firewall`)
- Creates an **isolated Virtual Private Cloud (VPC)** per environment.
- Defines **subnets**, or IP address ranges per region.
- Adds **firewall rules** like:
  - Who can SSH in
  - Whether HTTP/HTTPS is allowed
- These rules are configured using `allowed.json` and applied automatically.

---

### Load Balancer (`modules/gcp/load_balancer`)
- Sets up a **Global HTTP(S) Load Balancer**.
- Incoming internet traffic is routed through:
  - A **global forwarding rule** (receives traffic)
  - A **target HTTP proxy** (sends it to the correct app)
  - A **URL map** (defines backend behavior)
  - A **backend service** (connects to your VM instances)
- A health check is continuously monitoring the backend service.

You can inspect the full setup live using the script:
`scripts/manage/inspect-services.shell`

---

### Routing & NAT (`modules/gcp/networking.router.tf`)
- Creates **Cloud Routers** and **NAT gateways**.
- This allows your internal VMs (which don’t have public IPs) to:
  - Download software
  - Install updates
  - Communicate externally without exposing themselves to the internet

---

### Storage (`modules/gcp/storage`)
- Creates **Google Cloud Storage (GCS) buckets** for:
  - Terraform state files (the record of your infrastructure)
  - Uploading archives used by Cloud Functions
- Bucket behavior is controlled by `policies.json` and `tagging.json`
- If RBAC (role-based access control) is enabled, IAM permissions are applied automatically

---

### Cloud Functions (`modules/gcp/cloud_function`)
- Deploys **serverless functions** that run in response to HTTP requests.
- These functions:
  - Read configuration from a generated `config.json`
  - Simulate traffic (for autoscaling tests)
  - Run on demand
- All code and packages are zipped and uploaded using:
  `scripts/manage/package-functions.shell`

---

### Profiles / Service Accounts (`modules/gcp/profiles`)
- Creates and manages **IAM service accounts** based on `profiles.json`
- Automatically:
  - Generates keys
  - Binds roles
  - Deletes old accounts safely
- Service accounts are grouped using a `group` key so you can apply access controls to whole teams at once.

---

## 4. Terraform State Management

Terraform needs to **keep track of what it built**, and it does that via a `.tfstate` file.

This state file is:
- Stored in a **GCS bucket**
- Managed by `backend.tf`
- Automatically created or validated by the script:
  `scripts/manage/configure-backend.shell`
- The `scripts/manage/configure-workspaces.shell` script automates creation, selection, and inspection of Terraform workspaces based on JSON config. It ensures each environment maps cleanly to an isolated state scope.

If you ever destroy the environment, this script can download the `.tfstate` file and convert it to readable `.json` for inspection (in the `.local/` directory).

---

## 5. Inspections, Health Checks & Automation Scripts

Several custom **Bash scripts** help you validate and operate the environment consistently:

- `inspect-services.shell`: Shows the entire load balancer setup and health status
- `inspect-autoscaling.shell`: Runs a stress test and watches how autoscaling responds
- `configure-backend.shell`: Manages Terraform’s backend GCS bucket
- `configure-profiles.shell`: Creates and deletes IAM accounts and credentials
- `configure-terraform.shell`: Bootstraps Terraform execution across providers and workspaces
- `configure-workspaces.shell`: Manages Terraform workspace lifecycle actions
- `package-functions.shell`: Packages and uploads Python functions to GCS

Each script:
- Accepts flags like `--dry-run`, `--debug`, `--verbose`
- Reads shared config like `project.json`, `policies.json`, and provider-specific JSON files
- Is idempotent (safe to re-run)
- Designed for automated use in CI/CD pipelines and local operations

---

## 6. Execution Flow (What Happens When)

Here’s what happens when you set up a new environment from scratch:

1. You define or select the target environment in `project.json` (e.g., `dev`)

2. JSON configuration is loaded dynamically:
   - `dev.json` → environment-specific inputs
   - `policies.json` → which features are enabled
   - `profiles.json` → which credentials should exist

3. Terraform reads modules (`*.tf`) and builds:
   - VPC and subnets
   - VM instances in MIGs
   - Cloud Router and NAT
   - Global Load Balancer
   - Cloud Functions (if enabled)

4. Terraform backend state is stored in a GCS bucket named like:
   `<terraform-workspace>--<terraform-bucket-name>--<gcp-project-id>`

5. Post-deployment:
   - You can run inspection scripts to validate health and performance
   - Cloud Functions can simulate traffic
   - IAM accounts and credentials are auto-created

6. When tearing down:
   - Scripts handle state backup, safe deletion, and introspection
   - IAM keys and buckets are cleaned up conditionally

---

## Summary

This infrastructure system is:
- **Policy-driven**: JSON files decide what gets created
- **Modular**: Each feature (compute, networking, IAM, etc.) is isolated
- **Repeatable and Safe**: Every script has dry-run mode and safety checks
- **Extensible**: Supports multi-cloud in the future via config abstraction
- **Auditable**: All components can be inspected, described, and reported in JSON

This system empowers teams to manage cloud environments **confidently**, **transparently**, and **at scale**—even if you’re new to cloud or Terraform.

---

#### Download & install (latest version):

```bash
> target_package="google-cloud-cli-457.0.0-linux-x86_64.tar.gz" ;
> curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${target_package} ;
> tar -xf google-cloud-cli-*.tar.gz ;
> ./google-cloud-sdk/install.sh ;
```

---

#### Backup Local Configuration

```bash
> GCP_HOME="${HOME}/.gcp" ;
> GCP_BACKUPS="${GCP_HOME}/backups" ;

> mkdir -p ${GCP_BACKUPS}/ ;
> cp -prv ${HOME}/.config/gcloud ${GCP_BACKUPS}/ ;

> gcloud config configurations \
         list --format=json > ${HOME}/.gcp/backups/configurations.json ;
> gcloud config configurations \
         describe default > ${HOME}/.gcp/backups/default-configs.yaml ;
> gcloud iam service-accounts \
         list --format=json > ${HOME}/.gcp/backups/service-accounts.json ;
```

#### Purging GCP Project (default/current)

```bash
> gcloud projects delete $( gcloud config get-value project --quiet )
Your project will be deleted.

Do you want to continue (Y/n)?  Y

Deleted [https://cloudresourcemanager.googleapis.com/v1/projects/<gcp-project-name>].

You can undo this operation for a limited period by running the command below.
    $ gcloud projects undelete $( gcloud config get-value project --quiet )

See https://cloud.google.com/resource-manager/docs/creating-managing-projects
for information on shutting down projects.
```

---

#### Initializing GCP Configurations

##### Follow the prompts to:

- Authenticate with your Google account
- Choose a GCP project or create a new one
- Set a default region and zone

```bash
> gcloud init --console-only ;
```

##### This will allow Google Cloud SDK to:

- See, edit, configure, and delete your Google Cloud data and see the email address for your Google Account.
- View and sign in to your Google Cloud SQL instances
- View and manage your Google Compute Engine resources
- View and manage your applications deployed on Google App Engine

##### Copy the URL, open in browser manually, paste the code back in the terminal.

```bash
> gcloud init --console-only ;

Welcome! This command will take you through the configuration of gcloud.

Your current configuration has been set to: [default]

You can skip diagnostics next time by using the following flag:
  gcloud init --skip-diagnostics

Network diagnostic detects and fixes local network connection issues.
Checking network connection...done.
Reachability Check passed.
Network diagnostic passed (1/1 checks passed).

You must sign in to continue. Would you like to sign in (Y/n)?  Y

Go to the following link in your browser, and complete the sign-in prompts:

    https://accounts.google.com/o/oauth2/auth?response_type=code
    &client_id=<client-id>.apps.googleusercontent.com
    &redirect_uri=https://sdk.cloud.google.com/authcode.html
    &scope=openid+
    https://www.googleapis.com/auth/userinfo.email+
    https://www.googleapis.com/auth/cloud-platform+
    https://www.googleapis.com/auth/appengine.admin+
    https://www.googleapis.com/auth/sqlservice.login+
    https://www.googleapis.com/auth/compute+
    https://www.googleapis.com/auth/accounts.reauth
    &state=<account-state>
    &prompt=consent
    &token_usage=remote
    &access_type=offline
    &code_challenge=<code-challenge-query>
    &code_challenge_method=S256

Once finished, enter the verification code provided in your browser: <code-challenge-response>
You are signed in as: [<gcp-account-email>].

This account has no projects.

Would you like to create one? (Y/n)?  Y

Enter a Project ID. Note that a Project ID CANNOT be changed later.
Project IDs must be 6-30 characters (lowercase ASCII, digits, or
hyphens) in length and start with a lowercase letter. <gcp-project-name>
Waiting for [operations/create_project.global.<gcp-account-number>] to finish...done.
Your current project has been set to: [<gcp-project-name>].

Not setting default zone/region (this feature makes it easier to use
[gcloud compute] by setting an appropriate default value for the
--zone and --region flag).
See https://cloud.google.com/compute/docs/gcloud-compute section on how to set
default compute region and zone manually. If you would like [gcloud init] to be
able to do this for you the next time you run it, make sure the
Compute Engine API is enabled for your project on the
https://console.developers.google.com/apis page.

Created a default .boto configuration file at [${HOME}/.boto]. See this file and
[https://cloud.google.com/storage/docs/gsutil/commands/config] for more
information about configuring Google Cloud Storage.
The Google Cloud CLI is configured and ready to use!

* Commands that require authentication will use <gcp-account-email> by default
* Commands will reference project `<gcp-project-name>` by default
Run `gcloud help config` to learn how to change individual settings

This gcloud configuration is called [default].
You can create additional configurations if you work with multiple accounts and/or projects.
Run `gcloud topic configurations` to learn more.

Some things to try next:

* Run `gcloud --help` to see the Cloud Platform services you can interact with.
  And run `gcloud help COMMAND` to get help on any gcloud command.
* Run `gcloud topic --help` to learn about advanced features of the CLI like arg files and output formatting
* Run `gcloud cheat-sheet` to see a roster of go-to `gcloud` commands.
```

```bash
> gcloud services enable iam.googleapis.com compute.googleapis.com ;

ERROR: (gcloud.services.enable) FAILED_PRECONDITION:
       Billing account for project '<gcp-account-number>' is not found.
       Billing must be enabled for activation of service(s)
       'compute.googleapis.com,compute.googleapis.com,compute.googleapis.com' to proceed.
Help Token: <gcp-service-token>

- '@type': type.googleapis.com/google.rpc.PreconditionFailure
  violations:
  - subject: ?error_code=390001
             &project=<gcp-account-number>
             &services=compute.googleapis.com
             &services=compute.googleapis.com
             &services=compute.googleapis.com
    type: googleapis.com/billing-enabled

- '@type': type.googleapis.com/google.rpc.ErrorInfo
  domain: serviceusage.googleapis.com/billing-enabled
  metadata:
    project: '<gcp-account-number>'
    services: compute.googleapis.com,compute.googleapis.com,compute.googleapis.com
  reason: UREQ_PROJECT_BILLING_NOT_FOUND
```

```bash
> gcloud beta billing accounts list ;

You do not currently have this command group installed.  Using it
requires the installation of components: [beta]


Your current Google Cloud CLI version is: 517.0.0
Installing components from version: 517.0.0

┌─────────────────────────────────────────────┐
│     These components will be installed.     │
├──────────────────────┬────────────┬─────────┤
│         Name         │  Version   │   Size  │
├──────────────────────┼────────────┼─────────┤
│ gcloud Beta Commands │ 2025.03.29 │ < 1 MiB │
└──────────────────────┴────────────┴─────────┘

For the latest full release notes, please visit:
  https://cloud.google.com/sdk/release_notes

Once started, canceling this operation may leave your SDK installation in an inconsistent state.

Do you want to continue (Y/n)?  Y

Performing in place update...

╔════════════════════════════════════════════════════════════╗
╠═ Downloading: gcloud Beta Commands                        ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: gcloud Beta Commands                         ═╣
╚════════════════════════════════════════════════════════════╝

Performing post processing steps...done.

Update done!

Restarting command:
  $ gcloud beta billing accounts list

API [cloudbilling.googleapis.com] not enabled on project [<gcp-project-name>].
Would you like to enable and retry (this will take a few minutes)? (y/N)?  y

Enabling service [cloudbilling.googleapis.com] on project [<gcp-project-name>]...

ERROR: (gcloud.beta.billing.accounts.list) PERMISSION_DENIED:
Service Usage API has not been used in project <gcp-project-name> before or it is disabled.
Enable it by visiting https://console.developers.google.com/apis/api/serviceusage.googleapis.com/overview?project=<gcp-project-name> then retry.
If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.
This command is authenticated as <gcp-account-email> which is the active account specified by the [core/account] property.

Service Usage API has not been used in project <gcp-project-name> before or it is disabled.
Enable it by visiting https://console.developers.google.com/apis/api/serviceusage.googleapis.com/overview?project=<gcp-project-name> then retry.
If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.

Google developers console API activation
https://console.developers.google.com/apis/api/serviceusage.googleapis.com/overview?project=<gcp-project-name>

- '@type': type.googleapis.com/google.rpc.ErrorInfo
  domain: googleapis.com
  metadata:
    activationUrl: https://console.developers.google.com/apis/api/serviceusage.googleapis.com/overview?project=<gcp-project-name>
    consumer: projects/<gcp-project-name>
    containerInfo: <gcp-project-name>
    service: serviceusage.googleapis.com
    serviceTitle: Service Usage API
  reason: SERVICE_DISABLED
```

```bash
> gcloud beta billing accounts list --format=json ;

[
  {
    "currencyCode": "USD",
    "displayName": "My Billing Account",
    "masterBillingAccount": "",
    "name": "billingAccounts/<gcp-billing-account>",
    "open": true,
    "parent": ""
  }
]
```

```bash
> gcloud beta billing projects \
         link $( gcloud config get-value project --quiet ) \
         --billing-account <gcp-billing-account> ;

  billingAccountName: billingAccounts/<gcp-billing-account>
  billingEnabled: true
  name: projects/<gcp-project-name>/billingInfo
  projectId: <gcp-project-name>
```

```bash
> gcloud beta billing projects describe $( gcloud config get-value project) ;

API [cloudbilling.googleapis.com] not enabled on project [<gcp-project-number>].
Would you like to enable and retry (this will take a few minutes)? (y/N)?  y

Enabling service [cloudbilling.googleapis.com] on project [<gcp-project-number>]...
Operation "operations/acat.p2-<gcp-project-number>-<operation-unique-identifier>" finished successfully.
billingAccountName: billingAccounts/<gcp-billing-account>
billingEnabled: true
name: projects/<gcp-project-name>/billingInfo
projectId: <gcp-project-name>
```

```bash
> gcloud services enable \
         iam.googleapis.com compute.googleapis.com ;

  Operation "operations/acf.p2-<gcp-account-number>-<service-serial-number>" finished successfully.
```

```bash
> gcloud iam service-accounts \
         create gcp-cli-admin \
         --display-name "GCP CLI Admin" ;

  Created service account [gcp-cli-admin].
```

```bash
> gcloud projects add-iam-policy-binding <gcp-project-name> \
         --member="serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com" \
         --role="roles/owner" ;

  Updated IAM policy for project [<gcp-project-name>].

  bindings:
  - members:
  - serviceAccount:service-<gcp-account-number>@compute-system.iam.gserviceaccount.com

  role: roles/compute.serviceAgent
  - members:
  - serviceAccount:<gcp-account-number>-compute@developer.gserviceaccount.com
  - serviceAccount:<gcp-account-number>@cloudservices.gserviceaccount.com

  role: roles/editor
  - members:
  - serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com
  - user:<gcp-account-email>

  role: roles/owner

  etag: BwYyRXUa4Ps=
  version: 1
```

```bash
> gcloud iam service-accounts keys \
         create ${HOME}/.gcp/credentials.json \
         --iam-account gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com ;

  created key [<gcp-private-keyid>] of type [json] as [${HOME}/.gcp/credentials.json]
  for [gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com]
```

```bash
> ls -al ${HOME}/.gcp/credentials.json ;
  -rw-------  1 <user-id>  staff  2380 Jan  1 00:00 ${HOME}/.gcp/credentials.json
```

```bash
> bat ${HOME}/.gcp/credentials.json ;
     │ File: ${HOME}/.gcp/credentials.json
  1  │ {
  2  │   "type": "service_account",
  3  │   "project_id": "<gcp-project-name>",
  4  │   "private_key_id": "<gcp-private-keyid>",
  5  │   "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBAD...mUziEzFz5s=\n-----END PRIVATE KEY-----\n",
  6  │   "client_email": "gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com",
  7  │   "client_id": "<gcp-client-id>",
  8  │   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  9  │   "token_uri": "https://oauth2.googleapis.com/token",
 10  │   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
 11  │   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gcp-cli-admin%40<gcp-project-name>.iam.gserviceaccount.com",
 12  │   "universe_domain": "googleapis.com"
 13  │ }
```

```bash
> gcloud auth activate-service-account --key-file=${HOME}/.gcp/credentials.json ;

  Activated service account credentials for: [gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com]
```

```bash
# Extract abstract region from target config
> abstract_region=$(
    jq -r '.region' "${targets_config_path}"
  ) ;

# Resolve actual cloud region from project config
> target_region=$(
    jq -r --arg key "${abstract_region}" '.regions[$key]' "${project_config}"
  ) ;

> gcloud config set compute/region ${target_region} ;

  WARNING: Property validation for compute/region was skipped.
  Updated property [compute/region].

> gcloud config get-value compute/region ;
  <gcp-compute-region>
```

```bash
> target_zone=$(
    gcloud compute zones list \
      --filter="region:(${target_region})" \
      --limit=1 \
      --format="value(name)"
  ) ;

> gcloud config set compute/zone ${target_zone} ;
  WARNING: Property validation for compute/zone was skipped.
  Updated property [compute/zone].

> gcloud config get-value compute/zone ;
  <gpc-compute-zone>
```

```bash
> gcloud iam service-accounts keys \
         create ${HOME}/.gcp/credentials.json \
         --iam-account $(
            gcloud auth list --filter=status:ACTIVE --format="value(account)"
         ) ;
  # created key [<gcp-created-keyid>] of type [json]
  # as [${HOME}/.gcp/credentials.json] for [gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com]
```

---

```bash
> ./scripts/manage/configure-profiles.shell ;

    Usage: configure-profiles.shell [OPTIONS]

    Options:
    -c, --create            Create the service account and its associated credentials key (file) if they do not exist
    -d, --delete            Delete the service account and its associated credentials key (file)

    --help                  Show this help message and exit
    --dry-run               Print actions without executing them
    --verbose               Enable verbose output
    --debug                 Enable debug mode with trace output

    Examples:
    configure-profiles.shell --create ;
    configure-profiles.shell --delete ;

> ./scripts/manage/configure-profiles.shell --create ;

Account:     dev-account@<gcp-project-name>.iam.gserviceaccount.com
Description: Development environment service account
Credentials: ~/.config/gcloud/accounts/dev-credentials.json
```

```json
Created service account [dev-account].

{
  "displayName": "Development environment service account",
  "email": "dev-account@<gcp-project-name>.iam.gserviceaccount.com",
  "etag": "MDEwMjE5MjA=",
  "name": "projects/<gcp-project-name>/serviceAccounts/dev-account@<gcp-project-name>.iam.gserviceaccount.com",
  "oauth2ClientId": "<oauth2-client-id>",
  "projectId": "<gcp-project-name>",
  "uniqueId": "<oauth2-client-id>"
}
```

```bash
created key [gcp-private-keyid] of type [json]
as [~/.config/gcloud/accounts/dev-account--credentials.json]
for [dev-account@<gcp-project-name>.iam.gserviceaccount.com]
-rw-------  1 <user-id>  staff  2376 Jan 1 00:00 ~/.config/gcloud/accounts/dev-account--credentials.json

Account:     devops-account@<gcp-project-name>.iam.gserviceaccount.com
Description: DevOps service account
Credentials: ~/.config/gcloud/accounts/devops-account--credentials.json
```

```json
Created service account [devops-account].

{
  "displayName": "DevOps service account",
  "email": "devops-account@<gcp-project-name>.iam.gserviceaccount.com",
  "etag": "MDEwMjE5MjA=",
  "name": "projects/<gcp-project-name>/serviceAccounts/devops-account@<gcp-project-name>.iam.gserviceaccount.com",
  "oauth2ClientId": "116957529764710061292",
  "projectId": "<gcp-project-name>",
  "uniqueId": "116957529764710061292"
}
```

```bash
created key [gcp-private-keyid] of type [json]
as [~/.config/gcloud/accounts/devops-account--credentials.json]
for [devops-account@<gcp-project-name>.iam.gserviceaccount.com]
-rw-------  1 <user-id>  staff  2382 Jan 1 00:00 ~/.config/gcloud/accounts/devops-account--credentials.json

Account:     prod-account@<gcp-project-name>.iam.gserviceaccount.com
Description: Production environment service account
Credentials: ~/.config/gcloud/accounts/prod-account--credentials.json
```

```json
Created service account [prod-account].

{
  "displayName": "Production environment service account",
  "email": "prod-account@<gcp-project-name>.iam.gserviceaccount.com",
  "etag": "MDEwMjE5MjA=",
  "name": "projects/<gcp-project-name>/serviceAccounts/prod-account@<gcp-project-name>.iam.gserviceaccount.com",
  "oauth2ClientId": "117373193121071847420",
  "projectId": "<gcp-project-name>",
  "uniqueId": "117373193121071847420"
}
```

```bash
created key [gcp-private-keyid] of type [json]
as [~/.config/gcloud/accounts/prod-account--credentials.json]
for [prod-account@<gcp-project-name>.iam.gserviceaccount.com]
-rw-------  1 <user-id>  staff  2382 Jan 1 00:00 ~/.config/gcloud/accounts/prod-account--credentials.json

Account:     staging-account@<gcp-project-name>.iam.gserviceaccount.com
Description: Staging environment service account
Credentials: ~/.config/gcloud/accounts/staging-account--credentials.json
```

```json
Created service account [staging-account].

{
  "displayName": "Staging environment service account",
  "email": "staging-account@<gcp-project-name>.iam.gserviceaccount.com",
  "etag": "MDEwMjE5MjA=",
  "name": "projects/<gcp-project-name>/serviceAccounts/staging-account@<gcp-project-name>.iam.gserviceaccount.com",
  "oauth2ClientId": "<oauth2-client-id>",
  "projectId": "<gcp-project-name>",
  "uniqueId": "<oauth2-client-id>"
}
```

```bash
created key [<gcp-private-keyid>] of type [json]
as [~/.config/gcloud/accounts/staging-account--credentials.json]
for [staging-account@<gcp-project-name>.iam.gserviceaccount.com]
-rw-------  1 <user-id>  staff  2382 Jan 1 00:00 ~/.config/gcloud/accounts/staging-account--credentials.json
```

---

```bash
> ls -al ~/.config/gcloud/accounts/ ;

total 32
-rw-------   1 <user-id>  staff  2376 Jan 1 00:00 dev-credentials.json
-rw-------   1 <user-id>  staff  2382 Jan 1 00:00 devops-credentials.json
-rw-------   1 <user-id>  staff  2378 Jan 1 00:00 prod-credentials.json
-rw-------   1 <user-id>  staff  2384 Jan 1 00:00 staging-credentials.json
```

---

```bash
> ./scripts/manage/configure-profiles.shell --delete ;

deleted service account [dev-account@<gcp-project-name>.iam.gserviceaccount.com]
Deleting Credential: ~/.config/gcloud/accounts/dev-account--credentials.json

deleted service account [devops-account@<gcp-project-name>.iam.gserviceaccount.com]
Deleting Credential: ~/.config/gcloud/accounts/devops-account--credentials.json

deleted service account [prod-account@<gcp-project-name>.iam.gserviceaccount.com]
Deleting Credential: ~/.config/gcloud/accounts/prod-account--credentials.json

deleted service account [staging-account@<gcp-project-name>.iam.gserviceaccount.com]
Deleting Credential: ~/.config/gcloud/accounts/staging-account--credentials.json
```

---

```bash
export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/.gcp/credentials.json";
export GCP_CREDENTIALS="$( cat ${GOOGLE_APPLICATION_CREDENTIALS} | base64 )";

export GCP_PROJECT_ID=$(
  jq -r .project_id "${GOOGLE_APPLICATION_CREDENTIALS}"
) ; ## echo -e "Project ID: ${GCP_PROJECT_ID}" ;

export TF_VAR_gcp_project_id="${GCP_PROJECT_ID}";
```

##### Note: This will become active in the /locals.tf file:

```terraform
# File: /locals.tf
# Version: 0.1.0

# Description: Contains all local values used across modules

locals {

  # Load dispatcher
  project = jsondecode(file("${path.root}/project.json"))

  # Active provider ID
  provider_id = local.project.defaults.provider

  # Provider config (cloud-specific)
  provider_default = jsondecode(file("${path.root}/configs/providers/${local.provider_id}.json"))

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

  # Profiles (Accounts, Groups, Credentials, RBAC & access roles)
  profiles = jsondecode(file("${path.root}/configs/profiles.json"))

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

  # Profiles (Accounts, Groups, Credentials, RBAC & access roles)
  accounts = merge(
    try(local.profiles.accounts, {}),
    {
      tags = [
        for tag in try(local.tagging.providers[local.provider_id].accounts.tags, []) :
        tag.fixed ? tag.value : "${terraform.workspace}--${tag.value}"
      ]
    }
  )

  # Group Access Credentials (mapping): e.g.: local.group_credentials["devops"]
  group_credentials = {
    for group_key in distinct([
      for profile_key, profile in local.profiles.credentials :
      try(profile.group, null)
      if try(profile.group, null) != null
    ]) :
    group_key => {
      for profile_key, profile in local.profiles.credentials :
      profile_key => profile
      if try(profile.group, null) == group_key
    }
  }

  # Compute final backend config
  backend = merge(
    local.policies.storage.bucket,
    {
      name = (
        local.policies.storage.bucket.rbac ?
        "${terraform.workspace}--${local.policies.storage.bucket.name}--${local.project_id}" :
        local.policies.storage.bucket.name
      )
    }
  )

  # Autoscaling
  autoscaler = try(
    local.policies.autoscaling.profiles[local.workspace.policies.autoscaling],
    {}
  )

}
```

---

```bash
> gcloud auth list ;
                      Credentialed Accounts
ACTIVE  ACCOUNT
        <gcp-account-email>@gmail.com
*       gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com

To set the active account, run:
    $ gcloud config set account `ACCOUNT`

```

---

```bash
> gcloud services \
         enable cloudresourcemanager.googleapis.com \
         --format=json ;
  Operation "operations/acat.p2-<gcp-project-number>-<operation-unique-identifier>" finished successfully.
  []
```

```json
> gcloud services \
         list --enabled \
         --filter="config.name=cloudresourcemanager.googleapis.com" \
         --format=json ;

[
  {
    "config": {
      "authentication": {},
      "documentation": {
        "summary": "Creates, reads, and updates metadata for Google Cloud Platform resource containers."
      },
      "monitoring": {},
      "name": "cloudresourcemanager.googleapis.com",
      "quota": {},
      "title": "Cloud Resource Manager API",
      "usage": {
        "requirements": [
          "serviceusage.googleapis.com/tos/cloud"
        ]
      }
    },
    "name": "projects/<gcp-project-number>/services/cloudresourcemanager.googleapis.com",
    "parent": "projects/<gcp-project-number>",
    "state": "ENABLED"
  }
]
```

---

```bash
> gcloud services enable logging.googleapis.com --format=json ;
  Operation "operations/acat.p2-<gcp-project-number>-60cd72ae-54c4-4fe2-ac6b-3409e3b08058" finished successfully.
  []
```

```json
> gcloud services \
         list --enabled \
         --filter="config.name=logging.googleapis.com" \
         --format=json ;

[
  {
    "config": {
      "authentication": {},
      "documentation": {
        "summary": "Writes log entries and manages your Cloud Logging configuration."
      },
      "monitoredResources": [
        {
          "description": "A cloud logging specialization target schema of cloud.ChargedProject.",
          "displayName": "Cloud logging target",
          "labels": [
            {
              "description": "The monitored resource container. Could be project, workspace, etc.",
              "key": "resource_container"
            },
            {
              "description": "The service-specific notion of location.",
              "key": "location"
            },
            {
              "description": "The name of the API service with which the data is associated (e.g.,'logging.googleapis.com').",
              "key": "service"
            }
          ],
          "launchStage": "ALPHA",
          "type": "logging.googleapis.com/ChargedProject"
        }
      ],
      "monitoring": {
        "consumerDestinations": [
          {
            "metrics": [
              "logging.googleapis.com/billing/ingested_bytes",
              "logging.googleapis.com/billing/stored_bytes"
            ],
            "monitoredResource": "logging.googleapis.com/ChargedProject"
          }
        ]
      },
      "name": "logging.googleapis.com",
      "quota": {},
      "title": "Cloud Logging API",
      "usage": {
        "requirements": [
          "serviceusage.googleapis.com/tos/cloud"
        ]
      }
    },
    "name": "projects/<gcp-project-number>/services/logging.googleapis.com",
    "parent": "projects/<gcp-project-number>",
    "state": "ENABLED"
  }
]
```

---

##### Grant your gcp-cli-admin service account the necessary permissions on it:

```bash
> gcp_cli_admin="gcp-cli-admin@$( gcloud config get-value project --quiet )" ;
> gsutil iam ch serviceAccount:${gcp_cli_admin}.iam.gserviceaccount.com:roles/storage.admin \
                gs://${TERRAFORM_BACKEND_BUCKET} ;
```

---

##### Terraform State Backend setup

**Warning**: Terraform cannot create its own backend storage (GCS bucket) because its a pre-existing requirement to run. The bucket must:

- Already exist
- Be accessible by the service account

```bash
POLICIES_FILE="./configs/policies.json" ;
export TERRAFORM_BACKEND_BUCKET=$( jq -r '.storage.bucket.name' "${POLICIES_FILE}" ) ;
```

**Note**: You have the option to use a native request or use the ./scripts/manage/configure-backend.shell script to manage this process.

```bash
> gsutil mb -p <gcp-project-name> \
         -l us-west2 \
         -b on gs://${TERRAFORM_BACKEND_BUCKET} ;
```

or

```bash
> ./scripts/manage/configure-backend.shell ;

    Usage: configure-backend.shell [OPTIONS]

    Options:
    -l, --list              List the current bucket status and configuration
    -c, --create            Create the bucket if it does not exist
    -w, --download          Download and convert remote Terraform state to local JSON
    -d, --destroy           Destroy the bucket and optionally backup state locally

    -j, --project=PATH      Path to the project configuration file (default: ./project.json)
    -t, --target=NAME       Target workspace/environment name
    -p, --policies=PATH     Path to the policies configuration file (default: ./configs/policies.json)
    -n, --name=NAME         Name of the GCS bucket to manage
    -x, --prefix=NAME       State prefix path within the bucket

    --help                  Show this help message and exit
    --dry-run               Print actions without executing them
    --verbose               Enable verbose output
    --debug                 Enable debug mode with trace output

    Examples:
    configure-backend.shell --create --target=testing
    configure-backend.shell --list --target=prod --name=bucket-name
    configure-backend.shell --download --dry-run --verbose

> ./scripts/manage/configure-backend.shell --create ;

Creating gs://<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name>/...
Bucket gs://<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name> was created and confirmed!
```

```json
Bucket gs://<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name> exists.
Bucket configuration:

{
  "creation_time": "2025-04-11T01:35:21+0000",
  "default_storage_class": "STANDARD",
  "generation": 1744335321634073103,
  "location": "US",
  "location_type": "multi-region",
  "metageneration": 1,
  "name": "<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name>",
  "public_access_prevention": "inherited",
  "rpo": "DEFAULT",
  "soft_delete_policy": {
    "effectiveTime": "2025-04-11T01:35:21.888000+00:00",
    "retentionDurationSeconds": "604800"
  },
  "storage_url": "gs://<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name>/",
  "uniform_bucket_level_access": true,
  "update_time": "2025-04-11T01:35:21+0000"
}

Done.
```

```bash
> ./scripts/manage/configure-terraform.shell ;

    Usage: configure-terraform.shell [OPTIONS]

    Options:
    -i, --init              Initialize Terraform Engine & Modules
    -p, --policies=PATH     Path to the policies configuration file (default: ./configs/policies.json)
    -j, --project=PATH      Path to the project configuration file (default: ./project.json)
    -w, --workspace         Terraform target workspace: dev, staging, prod

    --help                  Show this help message and exit
    --dry-run               Print actions without executing them
    --verbose               Enable verbose output
    --debug                 Enable debug mode with trace output

    Examples:
    configure-terraform.shell --init --workspace='dev' ;

> ./scripts/manage/configure-terraform.shell --init ;

Terraform Bucket name:   <terraform-workspace>--<terraform-bucket-name>--<gcp-project-name>
Terraform Bucket prefix: terraform/state
```

```hcl
Initializing the backend...
Initializing modules...
Initializing provider plugins...
- Reusing previous version of hashicorp/google from the dependency lock file
- Using previously-installed hashicorp/google v6.29.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```json
> jq -r . .terraform/terraform.tfstate;

{
  "version": 3,
  "terraform_version": "1.11.4",
  "backend": {
    "type": "gcs",
    "config": {
      "access_token": null,
      "bucket": "<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name>",
      "credentials": null,
      "encryption_key": null,
      "impersonate_service_account": null,
      "impersonate_service_account_delegates": null,
      "kms_encryption_key": null,
      "prefix": "terraform/state",
      "storage_custom_endpoint": null
    },
    "hash": 1543364987
  }
}

gs://<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name>/terraform/state/default.tfstate

Done.
```

```bash
> gsutil ls gs://${terraform_bucket_name}/terraform/state/;
  gs://<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name>/terraform/state/default.tfstate
  gs://<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name>/terraform/state/dev.tfstate
  gs://<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name>/terraform/state/prod.tfstate
  gs://<terraform-workspace>--<terraform-bucket-name>--<gcp-project-name>/terraform/state/staging.tfstate
```

```bash
> ./scripts/manage/configure-workspaces.shell ;

    Usage: configure-workspaces.shell [OPTIONS]

    Options:
    -c, --create            Create Terraform workspaces: dev, staging, prod, ...
    -j, --project=PATH      Path to the project configuration file (default: ./project.json)
    -w, --workspace         Terraform target workspace: dev, staging, prod, ...

    --help                  Show this help message and exit
    --dry-run               Print actions without executing them
    --verbose               Enable verbose output
    --debug                 Enable debug mode with trace output

    Examples:
    configure-workspaces.shell --create --workspace='dev' ;

> ./scripts/manage/configure-workspaces.shell --create ;
```

```hcl
Creating workspace: dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
Creating workspace: prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
Creating workspace: staging
Created and switched to workspace "staging"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
Switched to workspace "dev".

Current Terraform Workspace: dev

Done.
```

```terraform
> terraform validate ;
  Success! The configuration is valid.
```

---

## Configuration Files

### `/backend.tf`

```hcl
# File: /backend.tf
# Version: 0.1.0

terraform {
  backend "gcs" {}
}
```

### `/providers.tf`

```hcl
# File: /providers.tf
# Version: 0.1.0

terraform {
  required_version = ">= 1.3.0"

  ## Optional version pinning — uncomment if stability is required
  # required_providers {
  #   google = {
  #     source  = "hashicorp/google"
  #     version = ">= 6.29.0"
  #   }
  # }

}

provider "google" {
  project = local.project_id
  region  = local.region
}
```

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
            "configure_backend": {
                "path": "./scripts/manage",
                "script": "configure-backend.shell"
            },
            "configure_profiles": {
                "path": "./scripts/manage",
                "script": "configure-profiles.shell"
            },
            "configure_terraform": {
                "path": "./scripts/manage",
                "script": "configure-terraform.shell"
            },
            "configure_workspaces": {
                "path": "./scripts/manage",
                "script": "configure-workspaces.shell"
            },
            "inspect_autoscaling": {
                "path": "./scripts/manage",
                "script": "inspect-autoscaling.shell"
            },
            "inspect_services": {
                "path": "./scripts/manage",
                "script": "inspect-services.shell"
            },
            "package_functions": {
                "path": "./scripts/manage",
                "script": "package-functions.shell"
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

---

### `/configs/providers/gcp.json`
Defines: provider, project, regions, compute types, services (cloud function, compute, firewall,load balancing, networking, and other infrastructure services.

**Ownership**: Infrastructure Administrators

```json
Config-File: /configs/providers/gcp.json

{
    "provider": "gcp",
    "project_id": "",
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
    "services": [
        "cloud_function",
        "compute_resources",
        "firewall_rules",
        "health_check",
        "http_forwarding",
        "load_balancer",
        "networking",
        "web_autoscaling",
        "web_backend"
    ]
}
```

```json
Config-File: /configs/services/gcp/cloud_function.json

{
    "enable": true,
    "auto_deploy": false,
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
    "invoker_member": "allUsers",
    "tags": []
}
```

```json
Config-File: /configs/services/gcp/compute_resources.json

{
    "instance_template_name_prefix": "web-server-template--",
    "instance_group_name": "web-servers-group",
    "base_instance_name": "web-server",
    "source_image": "ubuntu-os-cloud/ubuntu-2004-lts",
    "startup_script_path": "./scripts/configure/apache-webserver.shell",
    "health_check": {
        "name": "http-health-check",
        "interval": 5,
        "timeout": 5,
        "port": 80
    },
    "tags": []
}
```

```json
Config-File: /configs/services/gcp/firewall_rules.json

{
    "allow_ssh": {
        "name": "allow-ssh-restricted",
        "protocol": "tcp",
        "ports": [
            "22"
        ],
        "target_tags": [
            "ssh-access"
        ]
    },
    "allow_ssh_iap": {
        "name": "allow-ssh-iap",
        "protocol": "tcp",
        "ports": [
            "22"
        ],
        "target_tags": [
            "ssh-access"
        ]
    },
    "allow_http_https": {
        "name": "allow-http-https",
        "protocol": "tcp",
        "ports": [
            "80",
            "443"
        ]
    },
    "public_http_ranges": [
        "0.0.0.0/0"
    ],
    "tags": []
}
```

```json
Config-File: /configs/services/gcp/health_check.json

{
    "name": "http-health-check",
    "tags": []
}
```

```json
Config-File: /configs/services/gcp/http_forwarding.json

{
    "name": "http-forwarding-rule",
    "tags": []
}
```

```json
Config-File: /configs/services/gcp/load_balancer.json

{
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
    },
    "tags": []
}
```

```json
Config-File: /configs/services/gcp/networking.json

{
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
    },
    "tags": []
}
```

```json
Config-File: /configs/services/gcp/web_autoscaling.json

{
    "name": "web-autoscaling",
    "tags": []
}
```

```json
Config-File: /configs/services/gcp/web_backend.json

{
    "name": "web-backend-service",
    "tags": []
}
```

---

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

---

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
            "name": "terraform-prototype",
            "prefix": "terraform/state",
            "rbac": true,
            "lifecycle": {
                "rules": [
                    {
                        "action": {
                            "type": "Delete"
                        },
                        "condition": {
                            "age": 90,
                            "matchesStorageClass": [
                                "STANDARD"
                            ]
                        }
                    }
                ]
            }
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

---

### `/configs/profiles.json`
This is an abstraction mechanism to define services configurations.

**Ownership**: DevSecOps/DevNetOps Engieners

```json
{
    "accounts": {
        "users": {},
        "groups": {},
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
    "credentials": {
        "dev": {
            "id": "Development",
            "description": "Development environment service account",
            "name": "dev-account",
            "filename": "dev-credentials.json",
            "group": "devs",
            "environments": [
                "dev"
            ],
            "roles": [
                {
                    "resource": "bucket",
                    "role": "roles/storage.objectAdmin"
                },
                {
                    "resource": "project",
                    "role": "roles/viewer"
                }
            ]
        },
        "staging": {
            "id": "Staging",
            "description": "Staging environment service account",
            "name": "staging-account",
            "filename": "staging-credentials.json",
            "group": "staging",
            "environments": [
                "dev",
                "staging"
            ],
            "roles": [
                {
                    "resource": "bucket",
                    "role": "roles/storage.objectAdmin"
                },
                {
                    "resource": "project",
                    "role": "roles/logging.viewer"
                }
            ]
        },
        "prod": {
            "id": "Production",
            "description": "Production environment service account",
            "name": "prod-account",
            "filename": "prod-credentials.json",
            "group": "prod",
            "environments": [
                "prod"
            ],
            "roles": [
                {
                    "resource": "bucket",
                    "role": "roles/storage.objectAdmin"
                },
                {
                    "resource": "project",
                    "role": "roles/monitor.viewer"
                }
            ]
        },
        "devops": {
            "id": "DevOps",
            "description": "DevOps service account",
            "name": "devops-account",
            "filename": "devops-credentials.json",
            "group": "devops",
            "environments": [
                "dev",
                "staging",
                "prod"
            ],
            "roles": [
                {
                    "resource": "bucket",
                    "role": "roles/storage.objectAdmin"
                },
                {
                    "resource": "project",
                    "role": "roles/logging.logWriter"
                }
            ]
        }
    }
}
```

---

### `/configs/tagging.json`
This is an abstraction mechanism to define resource tagging within a unified control pane.<br />
Note: Tags could be fixed (as it's: nesting JSON structures, etc.) or dynamically tailored by well defined policies.

**Ownership**: Operations Management team

```json
{
    "providers": {
        "gcp": {
            "cloud_function": {
            },
            "compute": {
                "tags": [
                    {
                        "value": "ssh-access",
                        "fixed": true
                    },
                    {
                        "value": "http-server",
                        "fixed": false
                    }
                ]
            },
            "firewall": {
                "allow_ssh": {
                    "tags": [
                        {
                            "value": "ssh-access",
                            "fixed": true
                        }
                    ]
                },
                "allow_ssh_iap": {
                    "tags": [
                        {
                            "value": "ssh-access",
                            "fixed": true
                        }
                    ]
                }
            },
            "load_balancer": {
                "tags": [
                    {
                        "value": "load-balancer",
                        "fixed": false
                    }
                ]
            },
            "accounts": {
                "tags": [
                    {
                        "value": "service-accounts",
                        "fixed": false
                    }
                ]
            },
            "networking": {
                "tags": [
                    {
                        "value": "networking",
                        "fixed": false
                    }
                ]
            }
        }
    },
    "globals": {
    }
}
```

---

### `/configs/allowed.json`
Specifies IP ranges allowed through firewall ingress rules.
* DevOps IPS:  Whitelisting remote IP adddresses.
* Private IPS: Determine Allowed VPC Peering traffic.
* Console IPS: Allows for the GCP SSH Console access.

```json
{
  "devops_ips": [
    "<remote-ip-address>"
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
│   └── workflows/
│       └── terraform.yaml
├── .gitignore
├── .terraform/
│   ├── environment
│   ├── modules/
│   │   └── modules.json
│   ├── providers/
│   │   └── registry.terraform.io/
│   │       └── hashicorp/
│   │           └── google/
│   │               └── 6.29.0/
│   │                   └── darwin_amd64/
│   │                       ├── LICENSE.txt
│   │                       └── terraform-provider-google_v6.29.0_x5*
│   └── terraform.tfstate
├── .terraform.lock.hcl
├── backend.tf
├── configs/
│   ├── allowed.json
│   ├── policies.json
│   ├── profiles.json
│   ├── providers/
│   │   ├── aws.json
│   │   ├── azure.json
│   │   └── gcp.json
│   ├── README.md
│   ├── services/
│   │   └── gcp/
│   │       ├── cloud_function.json
│   │       ├── compute_resources.json
│   │       ├── firewall_rules.json
│   │       ├── health_check.json
│   │       ├── http_forwarding.json
│   │       ├── load_balancer.json
│   │       ├── networking.json
│   │       ├── web_autoscaling.json
│   │       └── web_backend.json
│   ├── tagging.json
│   └── targets/
│       ├── dev.json
│       ├── prod.json
│       └── staging.json
├── errata.md
├── LICENSE
├── locals.tf
├── logs/
│   └── README.md
├── main.tf
├── modules/
│   └── gcp/
│       ├── cloud_function/
│       │   ├── cloud_function.outputs.tf
│       │   ├── cloud_function.tf
│       │   ├── cloud_function.variables.tf
│       │   └── README.md
│       ├── compute/
│       │   ├── compute.outputs.tf
│       │   ├── compute.tf
│       │   ├── compute.variables.tf
│       │   └── README.md
│       ├── firewall/
│       │   ├── firewall.outputs.tf
│       │   ├── firewall.tf
│       │   ├── firewall.variables.tf
│       │   └── README.md
│       ├── load_balancer/
│       │   ├── load_balancer.outputs.tf
│       │   ├── load_balancer.tf
│       │   ├── load_balancer.variables.tf
│       │   └── README.md
│       ├── networking/
│       │   ├── networking.manage.tf
│       │   ├── networking.outputs.tf
│       │   ├── networking.router.tf
│       │   ├── networking.tf
│       │   ├── networking.variables.tf
│       │   └── README.md
│       ├── profiles/
│       │   ├── profiles.outputs.tf
│       │   ├── profiles.tf
│       │   ├── profiles.variables.tf
│       │   └── README.md
│       ├── README.md
│       └── storage/
│           ├── README.md
│           ├── storage.outputs.tf
│           ├── storage.tf
│           ├── storage.variables.tf
│           └── validating.steps
├── outputs.json
├── outputs.tf
├── packages/
│   ├── REDME.md
│   └── stressload-webservers.zip
├── project.json
├── providers.tf
├── README.md
├── reports/
│   ├── inspect.console
│   ├── queries/
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
│   ├── README.md
│   ├── terraform-apply.md
│   ├── terraform-destroy.md
│   ├── terraform-plan.md
│   └── webserver.console
├── scripts/
│   ├── configure/
│   │   └── apache-webserver.shell*
│   ├── docs/
│   │   ├── apache-webserver.md
│   │   ├── destroy-services.md
│   │   ├── gcloud-presets.md
│   │   ├── inspect-autoscaling.md
│   │   ├── inspect-services.md
│   │   ├── package-functions.md
│   │   └── terraform-backend.md
│   ├── manage/
│   │   ├── configure-backend.shell*
│   │   ├── configure-profiles.shell*
│   │   ├── configure-terraform.shell*
│   │   ├── configure-workspaces.shell*
│   │   ├── inspect-autoscaling.shell*
│   │   ├── inspect-services.shell*
│   │   └── package-functions.shell*
│   ├── others/
│   │   ├── destroy-resources.shell*
│   │   ├── destroy-services.shell*
│   │   ├── gcloud-presets.shell*
│   │   └── inspect-resources.shell
│   ├── README.md
│   └── stressload/
│       └── webservers/
│           ├── config.json
│           ├── main.py*
│           └── requirements.txt
└── variables.tf

36 directories, 118 files
```

---

## Design Philosophy

This project is engineered around the following principles:

- **Zero Touch Configuration**
  All infrastructure logic is driven by structured JSON files (`project.json`, `configs/`, `targets/`). No hardcoded values or inline definitions are allowed in Terraform files or scripts.

- **Multi-Environment Repeatability**
  The same codebase supports infinite environments (`dev`, `staging`, `prod`, etc.), each defined by its own target JSON config and Terraform workspace.

- **Security-First Posture**
  - No default public exposure (`0.0.0.0/0`)
  - IP-restricted firewall access
  - Service accounts scoped to minimal privilege
  - State managed remotely in private buckets

- **Automation-First Workflow**
  Shell scripts manage the full lifecycle: backend setup, provisioning, teardown, inspection, and Cloud Function deployment. CI/CD pipelines validate and enforce correct flows.

- **Cloud-Native Diagnostics**
  GCP-native introspection tools (e.g., `gcloud`, `gsutil`) are embedded in `inspect-services.shell`, `inspect-autoscaling.shell`, and `destroy-services.shell` to validate runtime infrastructure.

- **Terraform Best Practices**
  - State isolation via workspaces
  - Remote backend with auto-bucket creation
  - Strict separation between config, variables, and logic
  - Dynamic locals and centralized outputs for module interop

---

## Reviewer Evaluation Guide

### What to Evaluate

- **Security Discipline**
  Confirm firewall ingress is locked down. Inspect `allowed.json` and IAM bindings. Verify state bucket is private and access-controlled.

- **Automation Scope**
  End-to-end flow should be repeatable with `./scripts/manage/*.shell` or CI trigger. Validate dry-run behavior and error fallback handling.

- **Infrastructure Quality**
  Inspect module reuse, input/output separation, and config-driven behavior. Check if services are appropriately decoupled (compute, load balancer, function, etc.).

- **Error Handling**
  Validate safe destruct conditions, missing dependency warnings, and interactive prompts in destructive actions.

- **Real-World Readiness**
  Can the system be deployed to real GCP projects with minimal change? Are boundaries in place for destructive actions? Is monitoring/logging viable?

### Suggested Scenarios to Test

- Deploy `dev`, `staging`, and `prod` targets with different instance types and policies
- Attempt `terraform destroy` in `staging` or `prod` (should be blocked or gated)
- Modify `allowed.json` and validate new firewall rules are reflected
- Rotate credentials via `configure-profiles.shell` and verify IAM keys
- Run `inspect-autoscaling.shell` after applying `stressload` and confirm scale-out behavior
- Review outputs generated in `outputs.json` and their use in `package-functions.shell`

---

## Future Enhancements

- Multi-environment provisioning with JSON-driven isolation
- Provider-agnostic module support (AWS, Azure)
- DNS + certificate management via ACM + Cloud DNS
- GitHub OIDC for eliminating static credentials
- Multi-region failover for backend and load balancing
- Prometheus or GCP Ops integration for metrics and alerting
- Pre-commit hook integration (`tflint`, `tfsec`, `terraform fmt`)
- Terraform module publishing for VPC, MIG, Firewall, etc.
- Add custom CI stages for cost estimation and drift detection

---

## Project Components and Core Structure

This repository is structured for clarity, traceability, and reusability across cloud providers and deployment targets.

- **Terraform Modules (`modules/gcp/*`)**
  Define infrastructure components (e.g., networking, compute, firewall, load balancer, cloud functions) as reusable units.

- **JSON Configs (`configs/`)**
  Drive behavior dynamically. Includes environment targets, provider definitions, IAM profiles, policies, allowed networks, and tagging.

- **Shell Automation (`scripts/`)**
  Declarative entrypoints for operations including:
  - State backend management
  - IAM credential lifecycle
  - Stress testing
  - Service teardown
  - Diagnostics and reporting

- **CI/CD Pipeline (`.github/workflows/terraform.yaml`)**
  Handles plan, apply, teardown, artifact upload, and inspection logs using GitHub Actions.

---

## Core Terraform Files

- **`main.tf`**
  Entrypoint for module orchestration. Passes environment-aware locals into downstream modules.

- **`backend.tf`**
  Dynamically resolved backend configuration (GCS). Auto-created and validated via `configure-backend.shell`.

- **`providers.tf`**
  Declares cloud provider plugins based on variables passed from config.

- **`variables.tf`**
  Defines all inputs needed by `main.tf` and modules.

- **`outputs.tf`**
  Captures environment outputs (e.g., IPs, URLs, names) and feeds downstream automation.

---

## Meta Files

- **`.gitignore`**
  Ignores sensitive or local state files.

- **`.terraform.lock.hcl`**
  Ensures consistent provider versions.

- **`LICENSE`**
  Current licensing scheme (open source or proprietary).

---

## State and Logs

- **`.local/`**
  Locally stored state backups and downloaded `.tfstate` for debugging or destruction flows.

- **`outputs.json`**
  Terraform output exported in JSON format. Consumed by scripts for deployment and testing.

- **`logs/` + `reports/`**
  Execution traces, introspection results, and command snapshots stored for each deployment.

---

## Directory Hierarchy Summary

```bash
modules/        # Cloud-specific, reusable Terraform modules
configs/        # JSON-based environment and policy configurations
scripts/        # Automation shell and Python tools
.github/        # CI/CD GitHub Actions workflows and metadata
packages/       # Packaged artifacts (e.g., stressload function zips)
.local/         # Terraform state backups and downloads
logs/           # CLI tool outputs and internal logs
reports/        # GCP CLI JSON inspections and TF apply traces
```

---

## Inter-component Relationships

| Component                 | Depends On                      | Consumes                         |
|---------------------------|---------------------------------|----------------------------------|
| `main.tf`                 | `project.json`, `locals.tf`     | Passes inputs to modules         |
| `gcp/compute`             | `gcp/networking`, firewall      | Tags, startup scripts            |
| `gcp/load_balancer`       | `gcp/compute`                   | MIG, backend service, named port |
| `gcp/cloud_function`      | outputs.json, archive.zip       | Target URL, IAM email            |
| `configure-backend.shell` | `project.json`, `policies.json` | Creates GCS state bucket         |
| `configure-profiles.shell`| `profiles.json`                 | IAM keys and service accounts    |
| `inspect-services.shell`  | Terraform outputs               | IPs, health checks, MIGs         |
| `terraform.yaml`          | Everything                      | Orchestrates CI/CD flows         |

---

## Summary

This project delivers a fully modular, secure, and automation-driven infrastructure framework for Google Cloud. Every component—from IAM to compute to serverless—is driven by JSON-based configuration and managed through traceable workflows. Terraform modules are structured for reuse, and shell scripts expose deep lifecycle control. CI/CD pipelines ensure enforcement, validation, and observability across every stage. The system is production-capable, extensible to other providers, and designed to meet both operational rigor and developer velocity.
