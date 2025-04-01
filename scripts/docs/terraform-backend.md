# Terraform Backend Bootstrap Script

## File
`./scripts/manage/terraform-backend.shell`

## Version
`0.1.0`

---

## Purpose

This script manages the full lifecycle of a **Terraform remote backend** hosted on **Google Cloud Storage (GCS)**. It automates state bucket creation, inspection, backup, download, and safe destruction of backend infrastructure. It supports workspace-specific state management and acts as a foundational component for multi-environment infrastructure-as-code workflows.

By integrating this script into your development lifecycle, you ensure consistency and integrity of Terraform state files across all environments such as `dev`, `staging`, and `prod`. This helps reduce human error, supports disaster recovery, and improves collaboration among infrastructure teams.

---

## Features

- **Existence Check**: Verifies if the remote GCS bucket exists (default mode)
- **Bucket Creation**: Creates the Terraform state bucket (`--create`) with region and access policies
- **State Download**: Recursively fetches all `.tfstate` files across defined workspaces (`--download`)
- **Safe Destruction**: Backs up state files locally and deletes the bucket only after confirmation (`--destroy`)
- **Configuration Output**: Prints structured GCS bucket metadata (`--config`) for auditing or logging
- **Multi-workspace Support**: Dynamically reads `workspaces.json` to operate across all tracked environments
- **Cleanup Logic**: Automatically deletes empty state directories if no files were downloaded
- **Fail-Safe Controls**: Gracefully handles missing dependencies, invalid input, and permission errors

---

## Prerequisites

To use this script, ensure the following CLI tools are installed and configured:

- `gcloud`: Authenticated and set to your active GCP project
- `gsutil`: Required for interacting with GCS (list, copy, remove objects)
- `jq`: For parsing and extracting JSON configuration from `project.json` and `workspaces.json`

Make sure your environment is authenticated using:

```bash
gcloud auth login
gcloud config set project <your-project-id>
```

The script will fail gracefully if any of the required tools are missing.

---

## Arguments

| Argument      | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `--create`    | Creates the GCS bucket defined in `project.json` if it doesn’t already exist |
| `--download`  | Downloads all available Terraform state files to the `local-state/` folder   |
| `--destroy`   | Deletes the bucket only after local backup and 10-second confirmation window |
| `--config`    | Outputs the bucket configuration in JSON format                              |
| *(no arg)*    | Default mode: Check for bucket existence and return exit code                |

---

## Configuration Files

The script relies on the following JSON configuration files:

- `project.json` — Defines your backend GCS bucket:
  ```json
  {
    "storage": {
      "bucket": "my-terraform-backend-bucket"
    }
  }
  ```

- `workspaces.json` — Defines all named workspaces as keys under `targets`:
  ```json
  {
    "targets": {
      "dev": {},
      "staging": {},
      "prod": {}
    }
  }
  ```

These must be present in the same directory as the script.

---

## Behavior Overview

### ✔️ Bucket Check (default)
Checks whether the Terraform backend bucket exists:
```bash
./scripts/manage/terraform-backend.shell
```

### Bucket Creation
Creates the backend bucket with versioning, regional placement, and uniform access:
```bash
./scripts/manage/terraform-backend.shell --create
```

### Download Remote State Files
Fetches `.tfstate` files for each workspace and stores them in `local-state/<workspace>.tfstate`:
```bash
./scripts/manage/terraform-backend.shell --download
```

### Destroy Bucket
Backs up all workspace states locally, confirms with a 10-second prompt, and deletes the bucket:
```bash
./scripts/manage/terraform-backend.shell --destroy
```

### Describe Bucket
Returns JSON describing the bucket’s current configuration:
```bash
./scripts/manage/terraform-backend.shell --config
```

---

## Safety Mechanisms

- **Pre-checks**: Verifies bucket existence before any modification or deletion
- **Automatic Backup**: All states are downloaded before any destructive operation
- **Clean Exit**: Deletes `local-state/` if no files are found during download
- **Timed Confirmation**: Destroys only if explicitly confirmed within 10 seconds
- ⚠️ **Validation**: Handles edge cases like missing workspace keys or malformed JSON configs

---

## Use Cases

- **CI/CD Environment Setup**: Bootstrap remote state as part of pipeline initialization
- **Disaster Recovery**: Download `.tfstate` files after system failure or team transition
- **State Migration**: Back up and prepare for migration to a new backend provider
- **Security Reviews**: Print current bucket configuration for aud
