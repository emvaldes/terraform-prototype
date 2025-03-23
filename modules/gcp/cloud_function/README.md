# Terraform Module: GCP Cloud Function

**Version:** `0.1.0`

## Overview
This module provisions a Google Cloud Function configured for HTTP invocation, with a focus on stateless, event-driven workloads that are tightly integrated into a dynamic and modular infrastructure-as-code deployment pattern. Its primary role is to support auxiliary cloud-native operations such as stress testing, diagnostics, telemetry extraction, verification routines, and programmable test injection.

These functions are invoked via standard HTTPS endpoints and are built for full automation and ephemeral lifecycle management. The design ensures these functions can be provisioned, invoked, validated, and destroyed without manual intervention. The module leverages Terraform's output system to expose runtime information used across deployment scripts, inspection routines, and CI/CD workflows.

## Quick Capabilities Recap
- ✅ Deploys 2nd Gen Google Cloud Function using Terraform
- 🧰 Automatically packages and zips Python source code
- 🌐 Exposes HTTP endpoint used for autoscaling stress tests
- 🔧 Accepts environment variables (e.g., `TARGET_URL`) for ALB targets
- 📊 Uses native GCP Cloud Logging for observability
- 🔐 Applies IAM bindings and API enablement using scripts

## Key Features
- HTTP-triggered, runtime-configurable Google Cloud Function
- Source code originates from `scripts/stressload/webservers/main.py`
- Fully configurable runtime parameters: memory, timeout, entry point, IAM, and environment variables
- Terraform-native integration using output variables that are stored, parsed, and passed into downstream pipelines
- VPC access extensibility via serverless VPC connectors (if needed)
- Native support for integration with monitoring/logging pipelines in Google Cloud
- Stateless operation with optional configuration injection using `config.json`

## Files
- `cloud_function.tf`: Main resource block for the GCP Cloud Function
- `cloud_function.variables.tf`: Defines module-level input variables and defaults
- `cloud_function.outputs.tf`: Declares output values used by other modules, scripts, or CI pipelines

## Inputs
| Variable                 | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `function_name`          | The logical name of the function resource                                   |
| `runtime`                | The language runtime for the function (e.g., `python310`, `nodejs18`)        |
| `source_archive_bucket` | Name of the GCS bucket where the function archive is stored                 |
| `entry_point`            | Name of the function handler within the uploaded source archive             |
| `timeout`                | Maximum runtime for each function invocation (in seconds)                   |
| `available_memory_mb`    | Memory allocation for the function instance (typically 128–1024 MB)         |
| `environment_variables`  | Key-value map of environment variables made available to the function       |

## Outputs
| Output                   | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `url`                    | Fully-qualified HTTPS endpoint for function invocation                      |
| `service_account_email` | Email of the IAM identity used to run the function                          |
| `name`                   | Fully-resolved name of the deployed Google Cloud Function                   |

## Integration
- Packaged and zipped via `scripts/manage/package-functions.shell`
- Terraform outputs (such as URL and service account) are written to `outputs.json` for automation consumption
- Used in test pipelines to validate infrastructure functionality under load or during deployment smoke tests
- IAM role assignment can be configured manually or via outputs from the `profiles` module
- Fully pluggable into the Terraform-managed network stack, including VPC connectors if internal services are targeted
- Can be triggered manually, via CI, or programmatically from other services such as Compute Engine or Pub/Sub

## Security Considerations
- Uses purpose-bound, least-privilege service accounts created via IAM modules or defined per deployment environment
- Optionally restricts access to internal callers or authenticated clients using IAM policies or ingress restrictions
- Logs all invocations and execution details to GCP Cloud Logging for observability and incident response
- Sensitive environment variables should be injected through secure external secret managers or encrypted bindings

## Troubleshooting Notes
| Step | Issue                                 | Resolution                                                          |
|------|---------------------------------------|---------------------------------------------------------------------|
| 1    | 403: Cloud Functions API not enabled  | `gcloud services enable cloudfunctions.googleapis.com`              |
| 2    | 400: Cloud Build API not enabled      | `gcloud services enable cloudbuild.googleapis.com`                  |
| 3    | 403: Eventarc trigger failed          | `gcloud services enable eventarc.googleapis.com`                    |
| 4    | Trigger complexity blocked deployment | Removed `event_trigger`; switched to HTTP invocation                |
| 5    | 403 on HTTP invoke                    | Added IAM policy using `gcloud run services add-iam-policy-binding`|
| 6    | 500 from function                     | Injected correct `TARGET_URL` using `gcloud run services update`    |

## Sample Output
```bash
$ python3 scripts/stressload/webservers/main.py
INFO - Target URL: https://dev--webapp-stress-tester-....run.app
INFO - Status Code: 200
INFO - Response Time: 0.24s
✔️ Reached autoscaled instance: dev--web-server-tv02
```

## Best Practices
- Enable all required GCP APIs before deploying to avoid permission issues
- Prefer HTTP triggers for simplicity and direct integration with external systems
- Combine Terraform for core provisioning and `gcloud` CLI for post-deployment operations
- Validate environment variables such as `TARGET_URL` early in CI/CD workflows

## Planned Enhancements
- [ ] Inject `TARGET_URL` dynamically via Terraform instead of CLI
- [ ] Auto-detect Load Balancer IP from `outputs.tf`
- [ ] Migrate IAM policy bindings to Terraform (remove manual `gcloud`)
- [ ] Expand GitHub Action for full test automation

## Usage Notes
- This module is intended for short-lived, test-oriented, or auxiliary workloads
- Terraform apply and destroy cycles are fast and cost-efficient, making it ideal for ephemeral deployments
- Supports a JSON-based configuration handoff (`config.json`) that is passed in at runtime to control test parameters
- Particularly useful in performance validation workflows (e.g., during post-deploy `terraform apply` validations)
- Can be extended to accept CloudEvent or Pub/Sub-based triggers if configured outside HTTP mode

## Summary
The `cloud_function` module delivers a modular, automated, and secure method for provisioning on-demand compute endpoints in GCP. As part of this infrastructure framework, it supports a wide variety of cloud-native automation patterns including telemetry inspection, scaling verification, latency injection, and service availability monitoring. It interacts fluidly with other Terraform modules, CI pipelines, and runtime configuration layers—enabling high-confidence testing and deployment validation without the complexity of full-service orchestration.

