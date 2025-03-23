# Script: `terraform-backend.shell`

**Version:** `0.1.0`

**Purpose:**
This script provisions, inspects, downloads, and optionally destroys the remote Terraform backend infrastructure hosted on Google Cloud Storage (GCS). It offers complete lifecycle management of `.tfstate` storage for Terraform-managed environments. Beyond simple bucket creation, it supports multi-workspace state tracking, metadata auditing, and safe teardown—all aligned with infrastructure-as-code best practices.

## Location
`scripts/manage/terraform-backend.shell`

## Execution Context
- Must be executed from a Unix-like shell with `gcloud`, `gsutil`, and `jq` installed
- Requires a valid authenticated GCP session using:
  ```bash
  gcloud auth login
  gcloud config set project <your-project-id>
  ```
- Reads configuration from local `project.json` and `workspaces.json` files

## Execution Modes & Arguments
| Argument       | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `--create`     | Creates the Terraform state bucket using settings in `project.json`         |
| `--download`   | Downloads `.tfstate` files for all workspaces defined in `workspaces.json`  |
| `--destroy`    | Backs up state locally, prompts user, then deletes the GCS bucket           |
| `--config`     | Outputs current bucket configuration as structured JSON                     |
| *(no arg)*     | Default mode: Checks for bucket existence and prints status                 |

## Functional Summary
1. **Bucket Verification & Inspection** *(Default)*
   - Checks whether the backend bucket exists and reports status

2. **Backend Provisioning** `--create`
   - Creates the GCS bucket
   - Enables object versioning
   - Applies storage class, regional placement, and optional labels

3. **Multi-Workspace State Download** `--download`
   - Reads `workspaces.json` to enumerate available environments
   - Downloads `.tfstate` files for each to `.local/`
   - Deletes empty directories if no valid state is found

4. **Backend Destruction** `--destroy`
   - Downloads all state as backup
   - Prompts with a 10-second countdown before deletion
   - Destroys only after explicit confirmation

5. **Configuration Printout** `--config`
   - Reads current bucket state and prints full JSON description for auditing

## Technical Highlights
- **Idempotent Behavior:** Skips creation or destruction if bucket already matches target state
- **Fail-Safe Controls:** Prevents accidental deletion with timed confirmation and automatic backup
- **JSON-Driven:** Dynamically reads `project.json` and `workspaces.json` to drive logic and targets
- **Multi-Workspace Support:** Dynamically handles environments such as `dev`, `staging`, `prod`

## Required Configuration Files
### `project.json`
Defines the backend bucket:
```json
{
  "storage": {
    "bucket": "my-terraform-backend-bucket"
  }
}
```
### `workspaces.json`
Lists Terraform environments:
```json
{
  "targets": {
    "dev": {},
    "staging": {},
    "prod": {}
  }
}
```
These must be colocated with the script.

## Dependencies
- `gcloud` (GCP CLI)
- `gsutil` (for state file transfer)
- `jq` (for parsing configuration JSON)

## Example Usage
```bash
./scripts/manage/terraform-backend.shell --create     # Provision backend
./scripts/manage/terraform-backend.shell --download   # Backup all workspace state
./scripts/manage/terraform-backend.shell --destroy    # Destroy bucket with 10s confirmation
./scripts/manage/terraform-backend.shell --config     # Print GCS config
./scripts/manage/terraform-backend.shell              # Default: check bucket existence
```

## Extension Opportunities
- Accept CLI args to override `project.json` or specify target workspace
- Auto-update `backend.tf` to inject bucket and prefix dynamically
- Generate `.tfbackend` configuration for use with `terraform init -backend-config`
- Support bucket lifecycle rules for archival or cost optimization

## Use Cases
- **CI/CD Bootstrap:** Provision remote state before deploying infra in GitHub Actions, GitLab, etc.
- **Disaster Recovery:** Back up `.tfstate` across all environments before resets or rollbacks
- **Migration Readiness:** Capture full state archive before switching to another backend (e.g., Terraform Cloud)
- **Security Audit:** Validate backend compliance and retention via `--config` output

## Summary
The `terraform-backend.shell` script provides complete automation for Terraform state backend lifecycle management in GCP. Through modes like `--create`, `--download`, `--destroy`, and `--config`, it ensures state is centralized, versioned, recoverable, and auditable. It plays a foundational role in delivering robust, multi-environment, collaborative Terraform workflows.

