# Script: `destroy-services.shell`

**Version:** `0.1.0`

**Purpose:**
This script automates the destruction of GCP infrastructure provisioned via Terraform. It is typically used during teardown procedures in development or ephemeral environments, where infrastructure is short-lived and must be reliably removed without manual intervention.

## Location
`scripts/others/destroy-services.shell`

## Execution Context
- Must be run from the root directory of the project where Terraform configurations exist.
- Assumes that all necessary environment variables (e.g., `TF_VAR_*`) are exported or stored in Terraform variable files.
- Designed for local execution in a Unix-like shell (e.g., macOS, Linux).

## Functional Summary
This script performs the following actions:

1. **Safety Check Prompt**
   - Prompts the user to confirm the operation before proceeding. It uses a `[Yy]*` regex to validate affirmative user input.
   - If the user declines or provides invalid input, the script exits cleanly with a message.

2. **Terraform Destroy (JSON-Driven)**
   - Executes `terraform destroy` using `-var-file=configs/targets/dev.json` to target a specific environment (in this case, `dev`).
   - Outputs full destruction logs to the terminal.
   - Cleans up all resources defined under the current Terraform root module and any submodules.

3. **Post-Destruction Acknowledgment**
   - Displays a success message once infrastructure is destroyed.

## Technical Highlights
- **Inline Safety Confirmation:**
  Uses:
  ```bash
  read -p "Are you sure you want to destroy the DEV environment? [y/N] " answer
  ```
  This ensures users do not accidentally destroy live infrastructure.

- **Scoped to Dev Target:**
  Hardcoded to `configs/targets/dev.json` — this can be made dynamic by introducing an environment parameter or CLI argument in future iterations.

- **Exit Codes:**
  The script exits on failure or cancellation, ensuring other workflows don’t continue after a partial or aborted destruction.

## Dependencies
- Terraform CLI installed and available in `$PATH`
- Valid Terraform state and lock files present in the `.terraform/` directory

## Example Usage
```bash
chmod +x scripts/others/destroy-services.shell
./scripts/others/destroy-services.shell
```

## Extension Opportunities
- Accept target environment (`dev`, `staging`, `prod`) as a CLI parameter
- Add log file output for audit purposes
- Support selective module destruction (e.g., `terraform destroy -target=module.compute`)
- Chain this with cleanup scripts for Cloud Storage buckets or logs

## Warnings
⚠️ This script **permanently deletes all infrastructure** tied to the `dev.json` configuration. Use with extreme caution. Always validate which environment is targeted before proceeding.

## Summary
`destroy-services.shell` is a defensive, environment-specific automation utility to safely remove GCP infrastructure defined in Terraform. It provides confirmation prompts, scoped execution, and clean logging to ensure controlled teardown in non-production environments.
