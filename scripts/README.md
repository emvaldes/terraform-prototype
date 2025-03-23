# Directory: scripts/

## Overview

The `scripts/` directory contains automation utilities that extend the Terraform infrastructure with inspection, packaging, introspection, and stress-testing capabilities. These tools are used in both local and CI/CD pipelines to maintain secure, observable, and self-documenting infrastructure.

Scripts are categorized by function and referenced in `project.json` under the `scripts` object.

## Structure

| Path | Purpose |
|------|---------|
| `scripts/manage/` | Admin tasks: packaging functions, inspecting IAM, tracking services |
| `scripts/stressload/` | Stress-test HTTP endpoints using Cloud Functions or local Python |
| `scripts/packages/` | Output location for generated `.zip` archives (Cloud Functions) |

## Key Scripts

### `scripts/manage/package-functions.shell`
- Packages Cloud Function code from `scripts/stressload/webservers/`
- Builds `function_config.json` using Terraform outputs
- Verifies archive contents and deploy readiness

### `scripts/manage/profile-activity.shell`
- Merges IAM activity inspection (project-level + Terraform-managed)
- Displays service account roles and permissions with profile tagging

### `scripts/stressload/webservers/main.py`
- GCP-compatible HTTP-triggered Cloud Function
- Loads `config.json` for test parameters (target URL, duration, ramp-up)
- Emits logs to Cloud Logging

### `scripts/stressload/webservers/requirements.txt`
- Declares Python dependencies for stressload function
- Minimal set to support `requests` and `logging`

## DevSecOps Value

- Automation-first: all scripts are CI-compatible and repeatable
- No secrets hardcoded: function config injected via `config.json`
- Modular utilities that decouple logic from infrastructure
- All scripts follow strict naming, versioning, and logging standards

## Future Plans

- [ ] Add `scripts/manage/test-connectivity.shell` for live TCP/HTTP probes
- [ ] Build `scripts/manage/gen-docs.shell` to auto-document modules and configs
- [ ] Extend `main.py` to support AWS Lambda and Azure Functions
- [ ] Support tracing and service mesh integration (Jaeger, OpenTelemetry)

---

_This README describes the purpose and contents of `scripts/` as of April 1, 2025._
