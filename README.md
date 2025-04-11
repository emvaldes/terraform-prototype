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

Here’s a revised and more detailed documentation section that provides proper context and clarity for the shell automation tools you've built:

---

### 🔧 Shell Script Automation

The following scripts are used to automate and standardize infrastructure tasks across GCP environments. Each script supports modular argument parsing, dry-run support, and optional verbose/debug tracing.

#### `./scripts/manage/configure-backend.shell`
Handles the initialization, configuration, and validation of the Terraform GCS backend used for remote state storage.

- Creates or verifies the existence of the bucket for the given project/environment.
- Supports operations: `--create`, `--delete`, `--download`, `--list`
- Accepts custom overrides for project, policies, target workspace, bucket name, and state prefix.
- Automatically resolves and validates GCS bucket locations based on region context.
- Integrates with Terraform to convert `.tfstate` files to JSON for inspection.
- Fully idempotent and safe to re-run.

#### `./scripts/configure/apache-webserver.shell`
Automates the provisioning of compute VM instances configured to simulate HTTP traffic under various network load conditions.

- Dynamically deploys GCP compute instances using pre-defined profiles.
- Designed for benchmarking, load testing, or validating autoscaling policies.
- Config-driven: aligns with defined environment parameters and VM sizing.
- Automatically applies network tagging, firewall rules, and metadata configs.

#### `./scripts/manage/inspect-services.shell`
Audits and inspects Google Cloud Platform service configurations across environments.

- Enumerates Application Load Balancers (ALBs), backends, health checks, and forwarding rules.
- Compares current deployed state with Terraform-managed expectations.
- Can output identity and IAM role drift detection.
- Useful during post-deployment validation or compliance audits.

#### `./scripts/manage/inspect-autoscaling.shell`
Validates the current autoscaling configurations across instance groups.

- Reads autoscaler policies and evaluates thresholds, cool-downs, and target utilization.
- Helps verify that environment-specific scaling constraints are properly aligned.
- Useful for confirming dynamic compute capacity planning in CI/CD testing.

#### `./scripts/manage/destroy-services.shell`
Handles controlled teardown of deployed services and cleanup of associated GCP resources.

- Can destroy forwarding rules, backends, firewall rules, and instance groups.
- Safe by default: requires user confirmation or preset flags to proceed.
- Provides summary of affected resources before execution.

#### `./scripts/manage/gcloud-presets.shell`
Bootstraps and enforces consistent gcloud CLI environment settings across all systems.

- Applies default region, zone, and active account/project.
- Loads secure credentials and activates service accounts from managed config.
- Helps normalize local, CI/CD, or ephemeral environments before infrastructure interaction.

### Shared Features

- All scripts support execution flag expansion and verbose tracing
  - Execution flags: `--create`, `--list`, `--delete`, etc.
  - Toggle modes: `--dry-run`, `--verbose`, `--debug`
  - Central config loading via `project.json`, `policies.json`, or custom paths
- Error messages are human-readable and trace-friendly.
- Designed to be non-destructive unless explicitly confirmed.

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

#### 1. **Compute Layer** (`compute.tf`, `scrits/configure/apache-webserver.shell`)
- Manages lifecycle of VM instances across GCP regions
- Instance names, sizes, and replica counts sourced from `workspaces.json`
- Designed to integrate with GCP health checks and managed instance groups

#### 2. **Networking & Firewall** (`networking.tf`, `firewall.tf`, `allowed.json`)
- Creates isolated virtual networks (VPCs)
- Subnet definitions scoped per region
- Firewall ingress and egress rules enforced from `allowed.json` inputs

#### 3. **Load Balancing** (`router.tf`, `./scripts/manage/inspect-services.shell`)
- Instantiates HTTP(S) Global Load Balancer components:
  - Global forwarding rule
  - Target proxy
  - URL map and backend service
  - Health check with regional scope
- Scripted inspection returns JSON overview of all key load balancer components

#### 4. **Routing & NAT Configuration** (`router.tf`)
- Enables NAT gateway for instances without public IPs
- Ensures egress connectivity for patching, installation, and monitoring
- Cloud router setup is fully automated

#### 5. **State Management** (`./scripts/manage/configure-backend.shell`, `backend.tf`, `project.json`)
- Validates bucket existence or creates it securely using `gsutil`
- When `destroy` is run, conditionally downloads remote state to `.local/`
- Supports state file introspection and traceability via artifacts

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

API [cloudbilling.googleapis.com] not enabled on project [<gcp-project-number>]. Would you like to enable and retry (this will take a few minutes)? (y/N)?  y

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
> gcloud config set compute/region us-west2 ;

  WARNING: Property validation for compute/region was skipped.
  Updated property [compute/region].

> gcloud config get-value compute/region ;
  us-west2
```

```bash
> gcloud config set compute/zone us-west2-a ;
  WARNING: Property validation for compute/zone was skipped.
  Updated property [compute/zone].

> gcloud config get-value compute/zone ;
  us-west2-a
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
> ./scripts/manage/configure-profiles.shell --create ;

Account:     dev-account@<gcp-project-name>.iam.gserviceaccount.com
Description: Development environment service account
Credentials: ~/.config/gcloud/accounts/dev-account--credentials.json
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
created key [35730dcfb306a1d3a6b1764e1f351a9f6745f35e] of type [json]
as [~/.config/gcloud/accounts/dev-account--credentials.json]
for [dev-account@<gcp-project-name>.iam.gserviceaccount.com]
-rw-------  1 emvaldes  staff  2376 Apr 10 15:38 ~/.config/gcloud/accounts/dev-account--credentials.json

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
created key [c5ee50e9cc571aae4a27a12abee96a7b213098c3] of type [json]
as [~/.config/gcloud/accounts/devops-account--credentials.json]
for [devops-account@<gcp-project-name>.iam.gserviceaccount.com]
-rw-------  1 emvaldes  staff  2382 Apr 10 15:38 ~/.config/gcloud/accounts/devops-account--credentials.json

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
created key [1e02ed021d0654a70c6a751f5b196f3983800db7] of type [json]
as [~/.config/gcloud/accounts/prod-account--credentials.json]
for [prod-account@<gcp-project-name>.iam.gserviceaccount.com]
-rw-------  1 emvaldes  staff  2382 Apr 10 15:39 ~/.config/gcloud/accounts/prod-account--credentials.json

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
  "oauth2ClientId": "100743049498201815348",
  "projectId": "<gcp-project-name>",
  "uniqueId": "100743049498201815348"
}
```

```bash
created key [e9fad93e0999d2282a877ac38d07bc57b3d1baa5] of type [json]
as [~/.config/gcloud/accounts/staging-account--credentials.json]
for [staging-account@<gcp-project-name>.iam.gserviceaccount.com]
-rw-------  1 emvaldes  staff  2384 Apr 10 15:39 ~/.config/gcloud/accounts/staging-account--credentials.json
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

...

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
> ./scripts/manage/configure-backend.shell --list ;
Bucket does not exist: gs://<terraform-backend-bucket>

> ./scripts/manage/configure-backend.shell --create ;

Creating bucket: gs://<terraform-backend-bucket>
Creating gs://<terraform-backend-bucket>/...
Bucket created.
```

```json
Bucket configuration:

{
  "creation_time": "2025-01-01T007:00:00+0000",
  "default_storage_class": "STANDARD",
  "generation": <generation-index>,
  "location": "US",
  "location_type": "multi-region",
  "metageneration": 1,
  "name": "<terraform-backend-bucket>",
  "public_access_prevention": "inherited",
  "rpo": "DEFAULT",
  "soft_delete_policy": {
    "effectiveTime": "2025-01-01T00:00:00.000000+00:00",
    "retentionDurationSeconds": "604800"
  },
  "storage_url": "gs://<terraform-backend-bucket>/",
  "uniform_bucket_level_access": true,
  "update_time": "2025-01-01T00:00:00+0000"
}
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
$ gcloud services \
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
$ gcloud services \
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

```bash
function create_workspaces () {
    project_file="./project.json";
    workspace_keys=$( jq -r '.configs.targets.sets | keys[]' "${project_file}" );
    # echo -e "Detected environments: \n${workspace_keys}\n";
    echo -e; for ws in ${workspace_keys}; do
      if terraform workspace list | grep -qw "${ws}"; then
              echo -e "Workspace '${ws}' already exists.";
        else  echo -e "Creating workspace: ${ws}";
              terraform workspace new "${ws}";
      fi;
    done;
    default_workspace="$( jq -r '.defaults.target' "${project_file}" )";
    terraform workspace select ${default_workspace};
    echo -e "\nCurrent Terraform Workspace: $( terraform workspace show )\n";
    return 0;
  }; alias create-workspaces='create_workspaces';
```

---

```bash
function initialize_terraform () {
    local project_file="./project.json";
    local policies_file="./configs/policies.json";
    local project_name=$( gcloud config get-value project );  # Get the project name dynamically from GCP CLI
    local workspace=$( jq -r '.defaults.target' "${project_file}" );
    local storage=$( jq -r '.storage' "${policies_file}" );
    export terraform_bucket_name="$(
      echo -e "${storage}" \
         | jq -r --arg env "${workspace}" --arg project "${project_name}" \
           'if .bucket.rbac == true then "\($env)--\(.bucket.name)--\($project)"
            else .bucket.name end'
    )"; echo -e "Terraform Bucket name:   ${terraform_bucket_name}";
    ## e.g.: dev--terraform-prototype--<gcp-project-name>
    export terraform_bucket_prefix="$(
      jq -r '.bucket.prefix' <<< ${storage}
    )"; echo -e "Terraform Bucket prefix: ${terraform_bucket_prefix}";
    echo -e;
    ## e.g.: terraform/state
    terraform init \
              -backend-config="bucket=${terraform_bucket_name}" \
              -backend-config="prefix=${terraform_bucket_prefix}";
    if [[ -f .terraform/terraform.tfstate ]]; then
      jq -r . .terraform/terraform.tfstate;
      # jq -r '.backend.config.bucket' .terraform/terraform.tfstate
      # e.g.: dev--terraform-prototype--<gcp-project-name>
    fi;
    gsutil ls gs://${terraform_bucket_name}/terraform/state/;
    # e.g.: gs://dev--terraform-prototype--<gcp-project-name>/terraform/state/default.tfstate;
    ## Initializing Terraform Workspaces (default: ./projects.json->defaults.target)
    create_workspaces;
    return 0;
}; alias initialize-terraform='initialize_terraform';
```

```bash
> ./scripts/manage/configure-backend.shell --create ;

Action (Create): true

Creating gs://dev--terraform-prototype--<gcp-project-name>/...
Bucket gs://dev--terraform-prototype--<gcp-project-name> was created and confirmed!

Bucket gs://dev--terraform-prototype--<gcp-project-name> exists.
```

```json
Bucket configuration:

{
  "creation_time": "2025-04-11T01:35:21+0000",
  "default_storage_class": "STANDARD",
  "generation": 1744335321634073103,
  "location": "US",
  "location_type": "multi-region",
  "metageneration": 1,
  "name": "dev--terraform-prototype--<gcp-project-name>",
  "public_access_prevention": "inherited",
  "rpo": "DEFAULT",
  "soft_delete_policy": {
    "effectiveTime": "2025-04-11T01:35:21.888000+00:00",
    "retentionDurationSeconds": "604800"
  },
  "storage_url": "gs://dev--terraform-prototype--<gcp-project-name>/",
  "uniform_bucket_level_access": true,
  "update_time": "2025-04-11T01:35:21+0000"
}
```

```hcl
initialize-terraform ;

Terraform Bucket name:   dev--terraform-prototype--<gcp-project-name>
Terraform Bucket prefix: terraform/state

Initializing the backend...

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing modules...
Initializing provider plugins...
- Finding latest version of hashicorp/google...
- Installing hashicorp/google v6.29.0...
- Installed hashicorp/google v6.29.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```json
$ jq -r . .terraform/terraform.tfstate;

{
  "version": 3,
  "terraform_version": "1.11.4",
  "backend": {
    "type": "gcs",
    "config": {
      "access_token": null,
      "bucket": "<workspace>--<terraform-bucket-name>--<gcp-project-name>",
      "credentials": null,
      "encryption_key": null,
      "impersonate_service_account": null,
      "impersonate_service_account_delegates": null,
      "kms_encryption_key": null,
      "prefix": "terraform/state",
      "storage_custom_endpoint": null
    },
    "hash": <hash-number>
  }
}
```

```bash
> gsutil ls gs://${terraform_bucket_name}/terraform/state/;
  gs://dev--terraform-prototype--<gcp-project-name>/terraform/state/default.tfstate
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
```

```terraform
> terraform validate ;
  Success! The configuration is valid.
```

---

## Configuration Files

### `/backend.tf`

```json
# File: /backend.tf
# Version: 0.1.0

terraform {
  backend "gcs" {
    bucket = "terraform-prototype"
    prefix = "terraform/state"
  }
}
```

### `/providers.tf`

```json
# File: /providers.tf
# Version: 0.1.0

terraform {
  required_version = ">= 1.3.0"
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
            "configure_backend": {
                "path": "./scripts/manage",
                "script": "configure-backend.shell"
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
            "rbac": true
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
            "profiles": {
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
│   └── workflows/
│       └── terraform.yaml
├── .gitignore
├── .terraform/
│   ├── environment
│   ├── modules/
│   │   └── modules.json
│   ├── providers/
│   │   └── registry.terraform.io/
│   │       └── hashicorp/
│   │           └── google/
│   │               └── 6.28.0/
│   │                   └── darwin_amd64/
│   │                       ├── LICENSE.txt
│   │                       └── terraform-provider-google_v6.28.0_x5*
│   └── terraform.tfstate
├── .terraform.lock.hcl
├── backend.tf
├── configs/
│   ├── allowed.json
│   ├── policies.json
│   ├── providers/
│   │   ├── aws.json
│   │   ├── azure.json
│   │   └── gcp.json
│   ├── README.md
│   ├── services/
│   │   └── gcp/
│   │       ├── cloud_function.json
│   │       ├── compute_resources.json
│   │       ├── firewall_rules.json
│   │       ├── health_check.json
│   │       ├── http_forwarding.json
│   │       ├── load_balancer.json
│   │       ├── networking.json
│   │       ├── web_autoscaling.json
│   │       └── web_backend.json
│   ├── tagging.json
│   └── targets/
│       ├── dev.json
│       ├── prod.json
│       └── staging.json
├── LICENSE
├── locals.tf
├── logs/
│   └── README.md
├── main.tf
├── modules/
│   └── gcp/
│       ├── cloud_function/
│       │   ├── cloud_function.outputs.tf
│       │   ├── cloud_function.tf
│       │   ├── cloud_function.variables.tf
│       │   └── README.md
│       ├── compute/
│       │   ├── compute.outputs.tf
│       │   ├── compute.tf
│       │   ├── compute.variables.tf
│       │   └── README.md
│       ├── firewall/
│       │   ├── firewall.outputs.tf
│       │   ├── firewall.tf
│       │   ├── firewall.variables.tf
│       │   └── README.md
│       ├── load_balancer/
│       │   ├── load_balancer.outputs.tf
│       │   ├── load_balancer.tf
│       │   ├── load_balancer.variables.tf
│       │   └── README.md
│       ├── networking/
│       │   ├── networking.manage.tf
│       │   ├── networking.outputs.tf
│       │   ├── networking.router.tf
│       │   ├── networking.tf
│       │   ├── networking.variables.tf
│       │   └── README.md
│       ├── profiles/
│       │   ├── profiles.outputs.tf
│       │   ├── profiles.tf
│       │   ├── profiles.variables.tf
│       │   └── README.md
│       └── README.md
├── outputs.json
├── outputs.tf
├── packages/
│   ├── REDME.md
│   └── stressload-webservers.zip
├── project.json
├── providers.tf
├── README.md
├── reports/
│   ├── inspect.console
│   ├── queries/
│   │   ├── backend-services.json
│   │   ├── compute-instances.json
│   │   ├── firewall-rules-describe.json
│   │   ├── firewall-rules.json
│   │   ├── forwarding-rules.json
│   │   ├── health-checks.json
│   │   ├── instance-groups.json
│   │   ├── instance-template.json
│   │   ├── networks-listing.json
│   │   ├── operations-listing.json
│   │   ├── project-policies.json
│   │   ├── proxies-listing.json
│   │   ├── service-account.json
│   │   ├── storage-buckets.json
│   │   └── subnets-listing.json
│   ├── README.md
│   ├── terraform-apply.md
│   ├── terraform-destroy.md
│   ├── terraform-plan.md
│   └── webserver.console
├── scripts/
│   ├── configure/
│   │   └── apache-webserver.shell*
│   ├── docs/
│   │   ├── apache-webserver.md
│   │   ├── destroy-services.md
│   │   ├── gcloud-presets.md
│   │   ├── inspect-autoscaling.md
│   │   ├── inspect-services.md
│   │   ├── package-functions.md
│   │   └── terraform-backend.md
│   ├── manage/
│   │   ├── configure-backend.shell*
│   │   ├── destroy-services.shell*
│   │   ├── gcloud-presets.shell*
│   │   ├── inspect-autoscaling.shell*
│   │   ├── inspect-services.shell*
│   │   └── package-functions.shell*
│   ├── README.md
│   └── stressload/
│       └── webservers/
│           ├── config.json
│           ├── main.py
│           └── requirements.txt
└── variables.tf

34 directories, 106 files
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

## Project Components and Core Structure

This document outlines the foundational components of the infrastructure-as-code framework.
These elements are cloud-agnostic, configuration-driven, and designed to integrate seamlessly with the modules, scripts, and configs defined elsewhere.

---

## Core Terraform Files

### `main.tf`
Defines top-level orchestration logic. This file invokes modules, passing in dynamic variables derived from the config layer.

### `backend.tf`
Declares remote state backend configuration. This setup is resolved dynamically using the `configure-backend.shell` script.

### `providers.tf`
Activates the appropriate cloud provider based on dynamic variables.

### `variables.tf`
Lists all configurable variables for Terraform, ensuring modularity and reusability.

### `outputs.tf`
Exposes outputs like IP addresses, function URLs, or instance names for consumption by scripts and workflows.

---

## Meta Files

### `.gitignore`
Prevents temporary files and sensitive data from being committed.

### `.terraform.lock.hcl`
Locks Terraform provider versions for reproducibility.

### `LICENSE`
Open-source license declaration.

---

## State and Logs

### `.local/`
Contains local Terraform plans in both binary and JSON form.

### `outputs.json`
Captures all Terraform outputs for downstream scripting or inspection.

### `logs/README.md`
Provides an overview of logs collected during infrastructure execution.

### `reports/`
Stores GCP CLI responses and Terraform execution logs for debugging and traceability.

---

## Directory Hierarchy Summary

```bash
modules/        # Cloud-specific, reusable Terraform modules
configs/        # JSON-based environment and policy configurations
scripts/        # Automation shell and Python tools
.github/        # CI/CD GitHub Actions workflows and metadata
packages/       # Packaged artifacts (e.g., stressload function zips)
```

---

## Inter-component Relationships
- `project.json` drives logic across scripts and module invocation
- Terraform reads from `configs/providers` and `configs/targets` to resolve variables
- Outputs from modules are parsed into `outputs.json` and used by CI/CD and `inspect-*` scripts
- Logs and plans are collected into `reports/` and `.local/`

---

## Summary
This core project layout establishes a declarative, traceable, and modular foundation for infrastructure provisioning. All components interact via clearly defined contracts (variables, outputs, and configs), allowing seamless scalability and multi-cloud extensibility.
