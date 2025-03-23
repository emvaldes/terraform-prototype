# Terraform Module: GCP Profiles

**Version:** `0.1.0`

## Overview
This module provides a comprehensive solution for managing identity resources within Google Cloud Platform (GCP) using Terraform. It automates the creation of service accounts, assignment of IAM roles, and exposure of account metadata for integration with other modules in your infrastructure stack. This module is critical for establishing secure, consistent, and reusable identity patterns across development, staging, and production environments.

By applying the principle of least privilege, it ensures that each component of your system receives only the permissions it needs to operate. The module supports dynamic role assignment, modular environment deployment, and cross-module output consumption, making it ideal for organizations that require auditable, policy-compliant access control within Infrastructure as Code (IaC) workflows.

## Key Features
- Automatically creates one or more GCP service accounts with environment-specific naming conventions
- Assigns IAM roles from configurable role lists to restrict permissions based on least privilege
- Exposes service account email and ID outputs for consumption by other Terraform modules (e.g., `compute`, `cloud_function`)
- Compatible with `gcloud`, CI/CD pipelines, and function deployment workflows
- Enables tagging and labeling of service accounts to support audit logging and resource metadata filtering

## Files
- `profiles.tf`: Core logic for creating service accounts and attaching IAM roles
- `profiles.variables.tf`: Module input variable declarations
- `profiles.outputs.tf`: Defines output values including service account metadata and IDs

## Inputs
| Variable                 | Description                                                                                 |
|--------------------------|---------------------------------------------------------------------------------------------|
| `project_id`             | The GCP project ID where all service accounts and IAM roles will be managed               |
| `service_account_name`   | Base string used for generating service account names; supports suffixing by environment   |
| `roles`                  | List of IAM roles to assign to the created service account                                 |
| `labels`                 | Optional map of key-value pairs to label service accounts for metadata indexing           |
| `display_name`           | A user-friendly display name for easier identification of the service account in GCP UI    |

## Outputs
| Output                   | Description                                                                                 |
|--------------------------|---------------------------------------------------------------------------------------------|
| `service_account_email`  | The full email address of the created service account, usable in IAM bindings             |
| `service_account_id`     | The unique account ID (excluding domain) for reference in other modules and policies       |

## Integration
- Consumed by the `compute` module to define the identity under which VM instances run
- Referenced by the `cloud_function` module to grant scoped access for deployed functions
- Used in CI/CD pipelines for automated execution roles tied to deployment workflows
- Referenced in automation scripts for packaging, deployment, and stress-testing operations
- Helps establish a clear boundary between developer, runtime, and automation identities

## Design Considerations
- Enforces scoped permission models by restricting roles at the project level only
- Naming is abstracted and environment-specific to prevent collision and enable multi-tenant reuse
- Avoids generation of service account keys by default for improved security posture
- Supports conditional logic for adding labels or future feature flags
- Enables output chaining so downstream modules receive ready-to-use service account metadata

## Use Cases
- Provisioning compute instances with secure, role-specific service accounts
- Allowing Cloud Functions to read/write GCP resources such as Pub/Sub, Cloud Storage, or Secret Manager
- Creating role-limited automation accounts for use in CI/CD tools such as GitHub Actions or Cloud Build
- Establishing separate IAM profiles for stress-testing tools or external systems
- Replacing user-based IAM bindings with service account-driven role assignments for least-privilege compliance

## Extension Tips
- Enable key generation via toggle (only if managed securely through secret rotation or vaulting tools)
- Combine with an organizational IAM policy module to enforce org-wide constraints across all projects
- Use Terraform locals to construct environment-tiered IAM role sets (e.g., dev vs prod access)
- Support GKE Workload Identity binding to unify pod-to-service-account security without long-lived keys
- Extend with audit log filters or IAM Conditions to add advanced resource or time-bound access policies

## Security Considerations
- Always use unique service accounts per environment or function to minimize blast radius
- Avoid assignment of broad roles like `Editor`; favor fine-grained roles such as `roles/storage.objectViewer`
- Do not generate keys unless required; prefer default GCP-managed authentication wherever possible
- Enable audit logging for IAM bindings and monitor unexpected permission escalations
- Apply Conditions when assigning roles to introduce scope, resource, or time constraints

## Summary
The `gcp/profiles` module provides a declarative, reusable, and policy-aligned approach to identity provisioning within GCP. By centralizing the definition of service accounts and their IAM role assignments, this module enables consistent and scalable identity governance across all tiers of cloud infrastructure. It acts as a critical building block for any secure Infrastructure as Code architecture, bridging the gap between resource provisioning and cloud-native security best practices.

