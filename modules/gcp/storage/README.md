# Terraform Module: GCP Storage

**Version:** `0.1.0`

## Overview
This module manages Google Cloud Storage (GCS) buckets and optional IAM access control policies in a modular and policy-driven way. Designed for Terraform-managed infrastructure, it enables secure, traceable, and environment-aware provisioning of GCS resources with optional RBAC enforcement.

By supporting both static bindings and dynamic group-based IAM role assignment, this module ensures consistent bucket access patterns across environments and team roles while integrating cleanly with upstream automation (e.g., CI/CD, cloud functions, state backends).

## Key Features
- Creates a GCS bucket scoped to a specific project and environment
- Optionally applies IAM role bindings using group-based RBAC extracted from centralized credentials
- Supports both static and dynamic IAM role-member mappings
- Exposes binding metadata and effective member sets for downstream diagnostics or tooling
- Aligns with tagging/labeling logic for audit and metadata policies

## Files
- `storage.tf`: Core logic to create IAM bindings using dynamic RBAC or static policy maps
- `storage.variables.tf`: Declares inputs such as bucket name, RBAC flag, group credentials, and static bindings
- `storage.outputs.tf`: Exposes IAM bindings applied to the bucket

## Inputs

| Variable                   | Description                                                                 |
|----------------------------|-----------------------------------------------------------------------------|
| `project_id`               | The GCP project ID where the bucket exists                                  |
| `bucket_name`              | The name of the target GCS bucket                                           |
| `rbac_enabled`             | Boolean flag to enable dynamic IAM role binding using grouped credentials   |
| `group_credentials`        | Map of group → profile list; each profile includes roles and member details |
| `backend_policy_bindings` | Optional static role-to-members IAM map (overrides or augments dynamic RBAC)|
| `labels`                   | Optional map of key-value tags to apply to resources (if extended)          |

## Outputs

| Output              | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| `bucket_iam_bindings` | A map of IAM role bindings per role, including member lists and etags     |

## Integration
- Used to enforce RBAC rules on Terraform backend buckets
- Enables GCS access controls for cloud functions or automation pipelines
- Referenced in CI/CD for artifact storage, log archival, or output publishing
- Works alongside `configure-backend.shell` script to initialize bucket prior to Terraform usage

## Design Considerations
- RBAC logic is conditional based on `rbac_enabled`, allowing for flexibility across environments
- Role-member mappings are grouped by team (via `group_credentials`) for secure and auditable control
- Static `backend_policy_bindings` allows fine-grained override for legacy compatibility or exceptions
- Bucket is assumed to be pre-created by another module or script (this module does not manage bucket resource creation)

## Use Cases
- Apply team-specific access to backend state buckets (`terraform/state`)
- Grant CI/CD pipelines scoped access to storage resources
- Manage bucket-level access for environment-specific Cloud Functions
- Enforce principle of least privilege for GCS operations across projects

## Extension Tips
- Integrate with `storage_lifecycle_rules` to apply retention or archival policies
- Generate labels based on environment metadata for cost tracking or resource grouping
- Add support for uniform bucket-level access toggling or fine-grained permissions
- Validate binding consistency by exporting `bucket_iam_bindings` and comparing with GCP audit logs

## Security Considerations
- RBAC should be enabled only when credentials and group mappings are validated
- Avoid assigning broad roles (e.g., `roles/storage.admin`) unless explicitly justified
- Prefer uniform IAM bindings over per-object ACLs to simplify management and auditing
- Use tagging or labeling to trace usage across environments and enforce policy boundaries

## Summary
The `gcp/storage` module provides flexible and secure IAM binding capabilities for GCS buckets in Terraform-managed infrastructure. It supports dynamic and static binding modes, integrates with centralized credential logic, and helps enforce consistent access control policies across environments. Ideal for securing backend state, automation artifacts, and data buckets in cloud-native workflows.
