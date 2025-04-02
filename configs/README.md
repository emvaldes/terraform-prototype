# Directory: configs/

## Overview

The `configs/` directory contains the dynamic, declarative configuration files that govern all infrastructure behavior. This is the heart of the zero-config, zero-trust philosophy. It centralizes all environment-specific settings, region abstractions, and policy definitions.

All Terraform modules, GitHub workflows, and scripts rely on the data from this folder to render provider-specific values and behaviors.

## Structure

| File | Description |
|------|-------------|
| `gcp.tfvars` | Primary GCP-specific deployment settings (project, region, instance size) |
| `aws.tfvars` *(planned)* | Future support for AWS deployments |
| `azure.tfvars` *(planned)* | Future support for Azure deployments |

Each file is designed to map **abstracted values** (like `region = west`) to real values (`us-west2`, etc.), ensuring portability and multi-cloud alignment.

## Example: `gcp.tfvars`
```hcl
cloud_provider = "gcp"
gcp_project_id = "static-lead-454601-q1"
region         = "us-west2"
instance_size  = "e2-micro"
```

## Purpose and Integration

- Used as input to Terraform via `-var-file=configs/gcp.tfvars`
- Parsed by scripts to inject region/type into deployment logic
- Supports GitHub workflow overrides by environment input

## DevSecOps Value

- Promotes **configuration-as-policy** across all workflows
- Enables **fully declarative infra**—no manual updates to scripts or Terraform files
- Enforces consistent regional naming and instance abstraction
- Supports **environment onboarding** via new `.tfvars` without refactoring code

## Future Plans

- [ ] Centralize configuration merging using `project.json` references
- [ ] Add dynamic validation schema (e.g., `configs/schema.json`) for type safety
- [ ] Encrypt sensitive `.tfvars` values using GPG or Vault
- [ ] Add `azure.tfvars` and `aws.tfvars` to complete multi-cloud rollout

---

_This README documents the purpose of `configs/` as of April 1, 2025._

