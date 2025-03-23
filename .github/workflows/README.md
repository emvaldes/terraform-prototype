# Terraform GitHub Actions Workflow

## File
`File: .github/workflows/terraform.yaml`

## Version
`Version: 0.1.0`

---

## Overview
This GitHub Actions workflow automates the full lifecycle of Terraform-based infrastructure provisioning on **Google Cloud Platform (GCP)**. Designed for flexibility, security, and maintainability, it supports the following actions across multiple environments (`dev`, `staging`, `prod`):

- Terraform configuration validation
- Plan generation for infrastructure changes
- Deployment and provisioning of cloud resources
- Controlled destruction with safety checks and state backup

The workflow is tightly integrated with Terraform, GCP tooling (`gcloud`), and custom JSON-based configuration files to dynamically adjust to the selected environment and input parameters. It ensures consistent, reproducible deployments and applies DevOps best practices to infrastructure management.

This workflow is particularly useful for teams aiming to achieve infrastructure automation and compliance via CI/CD pipelines while preserving security and auditability.

---

## Trigger Mechanism

The workflow is **manually triggered** using GitHub’s `workflow_dispatch` event, enabling developers or DevOps engineers to select specific inputs when initiating a pipeline run.

### Inputs
- **`target_environment`** (string, optional): Defines the workspace to target. Defaults to `dev`. Accepted values:
  - `dev`
  - `staging`
  - `prod`

- **`action`** (string, optional): Determines which Terraform operation to execute. Defaults to `validate`. Options include:
  - `validate`
  - `plan`
  - `apply`
  - `destroy`

This setup supports fine-grained control over when and how infrastructure changes are deployed.

---

## Environment Preparation

The pipeline configures runtime variables and credentials required for Terraform and GCP access:

- Sets the `TF_WORKSPACE` environment variable from the input
- Decodes a Base64-encoded GCP service account key from GitHub Secrets (`GCP_CREDENTIALS`) into `credentials.json`
- Uses `jq` to parse `workspaces.json` and extract the default region and forwarding rule name relevant to the chosen environment
- Stores extracted values in GitHub environment variables for downstream steps

---

## Toolchain Installation

The following dependencies are installed to ensure a reproducible and consistent build environment:
- **Google Cloud SDK** (via shell installation)
- **jq**, **curl**, and **unzip** (via `apt-get`)

Installation logs are written to `gcloud-sdk-install.log` and uploaded as an artifact. This step enables full visibility and helps with troubleshooting any toolchain-related issues.

---

## GCP Authentication and Project Context

- Activates the service account via `gcloud auth activate-service-account`
- Sets the current project using `gcloud config set project`
- Ensures that all Terraform and `gcloud` commands are executed within the correct GCP project context

---

## Cloud Diagnostics and Environment Introspection

The workflow includes comprehensive GCP diagnostics prior to any Terraform command. These checks are useful for debugging and auditing:

- Authentication state (`gcloud auth list`)
- Current configurations (`gcloud config list`)
- GCP project metadata (`gcloud projects describe`)
- Compute quotas and usage (`gcloud compute project-info describe`)
- Available regions and zones (`gcloud compute regions/zones list`)
- VPC networks (`gcloud compute networks list`)
- Running instances (`gcloud compute instances list`)
- Enabled services (`gcloud services list --enabled`)
- IAM service accounts (`gcloud iam service-accounts list`)

All diagnostic outputs are formatted as JSON and printed to the workflow logs for review.

---

## Terraform Backend Initialization & Workspace Management

- Runs the `scripts/setup-backend.shell` script to ensure the remote state bucket exists
  - If the bucket is missing, it is created automatically with the `--create` flag
- Executes `terraform init` to initialize the backend and prepare for operations
- Manages workspace selection using `terraform workspace select` or `new` to ensure operations are scoped correctly to the desired environment

---

## Terraform Execution Logic

The pipeline branches based on the selected `action`:

### Validate
- Performs static analysis using `terraform validate`
- Ensures configuration is syntactically correct and complete

### Plan
- Executes `terraform plan` with logging enabled (`TF_LOG=INFO`)
- Stores the output in a `tfplan` file, which can be used later for `apply`

### Apply
- Runs `terraform apply` with `-auto-approve` using the previously created plan
- Applies infrastructure changes and provisions new resources

### Destroy *(restricted to `dev` only)*
- Checks if the target environment is `dev` before proceeding
- Downloads the current remote state via `setup-backend.shell --download`
- Uploads the backup state to GitHub as `terraform-state-backup-<run_id>`
- Executes `terraform destroy` to tear down infrastructure

---

## Post-Deployment Service Inspection

After a successful `apply`, the workflow executes the `scripts/inspect-services.shell` script with the forwarding rule name as a parameter. This script prints enriched metadata about:
- Global forwarding rules
- Target HTTP proxies
- URL maps
- Backend services
- Health checks and their statuses

This step ensures that all critical load balancer components are provisioned correctly and are functioning as expected.

---

## Additional Notes

- `destroy` is gated by an environment check and is disabled in `staging` and `prod`
- All workspace-related defaults are extracted from `workspaces.json`, removing the need for `.tfvars`
- A commented-out test block exists for performing an HTTP `curl` request against the deployed load balancer
- All significant outputs, logs, and state artifacts are uploaded to GitHub for later inspection or recovery

---

## Final Summary

This GitHub Actions workflow delivers a production-grade automation pipeline for Terraform deployments to GCP. It combines environment-aware provisioning with robust diagnostics, clear state management, and secure operation enforcement. By leveraging structured JSON inputs, it avoids hardcoded values and supports seamless environment transitions.

Ideal for DevOps engineers, infrastructure specialists, and platform teams seeking to implement a secure, extensible, and transparent CI/CD workflow for infrastructure management.
