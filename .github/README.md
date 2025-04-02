# Directory: .github/

## Overview

The `.github/` directory defines GitHub-native automation for infrastructure deployment, testing, and teardown. It leverages `workflow_dispatch` events, configuration inputs, and strict zero-trust CI/CD practices to ensure controlled, auditable, and repeatable infrastructure provisioning.

All workflows are environment-aware and configuration-driven using `project.json`, `workspaces.json`, and Terraform outputs.

## Structure

| File | Purpose |
|------|---------|
| `.github/workflows/terraform.yaml` | Primary CI/CD workflow for deploy/test/teardown |

## terraform.yaml

### Dispatch Inputs
- `cloud`: Select GCP/AWS/Azure (defaults to value in `project.json`)
- `env`: Environment name (e.g., `dev`, `pipeline`, or adhoc)
- `logging_level`: Controls TF_LOG and debug verbosity

### Job Breakdown
| Job | Description |
|-----|-------------|
| `configure` | Load config from JSON files and resolve all paths |
| `terraform-init` | Initialize backend and state files |
| `terraform-plan` | Plan changes, output logs and preview state |
| `terraform-deploy` | Apply infrastructure using configs |
| `terraform-package` | Package function (via `package-functions.shell`) |
| `terraform-output` | Capture outputs, save artifacts |
| `terraform-teardown` | Optional: destroy if in test mode |

### Features
- All Terraform steps run with `-var-file=configs/*.tfvars`
- Supports `test` mode to deploy, validate, and destroy ephemeral environments
- Uploads state file, output JSON, and debug logs as GitHub artifacts
- Uses `${{ env.* }}` syntax to maintain traceability

## DevSecOps Integration

- ✅ CI-only access to apply/destroy
- 🔒 No local/CLI manual Terraform operations allowed
- 📁 Uploads all state and plan logs for audit/compliance
- 🧪 Test mode ensures pipeline reliability
- 📌 Ephemeral deploys using temporary config injection

## Future Plans

- [ ] Add scheduled test runs to validate infrastructure drift
- [ ] Integrate pre-deploy policy check (`terraform validate + tflint`)
- [ ] Restrict destroy permissions to specific GitHub actors
- [ ] Embed PGP validation for plans via `terraform show | gpg`

---

_This README documents `.github/` workflows and CI/CD integrations as of April 1, 2025._

