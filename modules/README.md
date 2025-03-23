# Directory: modules/

## Overview

The `modules/` directory contains reusable, scoped Terraform modules responsible for provisioning infrastructure components across cloud providers. Each module encapsulates a distinct set of resources with input variables, outputs, and built-in security rules.

Modules follow strict zero-trust, least-privilege, and config-driven patterns to ensure predictable behavior and minimal manual input.

## Structure

| Module Path | Description |
|-------------|-------------|
| `modules/gcp/networking/` | VPC, subnets, NAT, private service access, and router configuration |
| `modules/gcp/compute/` | Web server instance template, group, autoscaling, and instance policies |
| `modules/gcp/loadbalancer/` | Backend service, forwarding rules, URL maps, health checks |
| `modules/gcp/cloud_function/` | GCP Cloud Function deployment, IAM, logging, and permissions |

## Module Standards

Each module contains:
- `main.tf`: Core infrastructure resources
- `variables.tf`: Explicitly declared, typed, documented inputs
- `outputs.tf`: Exposed outputs used by other modules or workflows
- `README.md` *(to be generated individually)*

## Example: GCP Networking Module
📂 `modules/gcp/networking/`

- Provisions primary VPC with routing and NAT
- Enables PSA (Private Service Access) for Cloud Functions
- Exposes network ID and subnet CIDRs via outputs

## DevSecOps Value

- 🔒 No implicit privileges: all IAM bindings declared per module
- 🔁 Reusable across cloud providers (AWS/Azure support planned)
- 📜 Outputs consumed by automation to build `config.json`
- 🧪 Fully testable via Terraform CI with mock inputs

## Future Plans

- [ ] Add `modules/aws/*` and `modules/azure/*`
- [ ] Document and test each module with example configs
- [ ] Add module-level compliance policies using Sentinel or OPA
- [ ] Integrate module README auto-generation from `variables.tf`

---

_This README describes the modular structure of `modules/` as of April 1, 2025._

