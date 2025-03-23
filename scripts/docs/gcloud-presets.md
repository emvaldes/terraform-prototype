# Script: `gcloud-presets.shell`

**Version:** `0.1.0`

**Purpose:**
This script configures essential GCP project-wide settings to prepare the environment for Terraform-based infrastructure provisioning. It defines key variables and environment presets that influence all downstream `gcloud` and `terraform` operations. Its main role is to enforce consistency across CLI workflows and reduce manual error in project selection, region targeting, and authentication.

## Location
`scripts/others/gcloud-presets.shell`

## Execution Context
- Intended to be sourced, not executed. Run with:
  ```bash
  source scripts/others/gcloud-presets.shell
  ```
- Should be run at the beginning of each session or before initiating Terraform actions.

## Functional Summary
This script sets the following environment presets:

1. **GCP Project Configuration**
   - Assigns the target GCP project ID using `gcloud config set project $PROJECT_ID`
   - Ensures all GCP CLI commands use the correct project context

2. **GCP Compute Region and Zone**
   - Sets the default compute region (e.g., `us-central1`)
   - Sets the default compute zone (e.g., `us-central1-a`) using `gcloud config set`

3. **Terraform Input Variables**
   - Exports critical `TF_VAR_*` environment variables, including:
     - `TF_VAR_project_id`
     - `TF_VAR_region`
     - `TF_VAR_credentials_file` (for Terraform to authenticate properly)

4. **Credential File Binding**
   - Sets and confirms the path to the local service account key file for authentication
   - The script assumes the key file is already downloaded and present locally

## Technical Highlights
- **Idempotent Setup:** Variables are re-exported on every sourcing, allowing updates between sessions
- **Service Account Usage:** Leverages `GOOGLE_APPLICATION_CREDENTIALS` and Terraform-specific `TF_VAR_*` for seamless IAM integration
- **Environment Enforcer:** Prevents accidental mis-targeting of the wrong GCP project or region by hardcoding expected values

## Dependencies
- `gcloud` CLI must be installed and authenticated locally
- Service account key (JSON) must be pre-generated and locally available

## Example Usage
```bash
source scripts/others/gcloud-presets.shell
```
> Note: Running it with `bash` or `sh` will spawn a subprocess and discard exported variables.

## Extension Opportunities
- Parameterize the project, region, or zone with `read` prompts or CLI arguments
- Validate file existence (`[ -f $CREDENTIALS_FILE ]`) before exporting
- Auto-select the most recently used GCP project from `gcloud config list`

## Warnings
⚠️ Do not hardcode sensitive credentials into the script. It assumes your credentials file is secure and locally scoped.

## Summary
`gcloud-presets.shell` is a foundational shell utility used to prepare the GCP environment for Terraform workflows. It ensures all Terraform executions are regionally scoped, project-bound, and securely authenticated, reducing operational overhead and boosting reproducibility across deployments.
