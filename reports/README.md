# Directory: reports/

## Overview

The `reports/` directory contains structured output data, audit results, and inspection summaries generated after deployments. It serves as a passive observability layer—no logic runs from this folder directly, but its contents provide transparency and traceability.

These reports are generated by various inspection scripts and GitHub Actions after Terraform deployments and function packaging.

Note: This was an exploratory effort for me to learn the GCloud API and its capabilities. Knowing and understanding how it works and its capabilities was crucial for me to produce all this work. The /scripts/others/destroy-services.shell is a demonstration on what to do in case Terraform goes bad and you are left with an unmanaged infrastructure and orphan resources.

## Structure

| File/Pattern       | Description                                                    |
| ------------------ | -------------------------------------------------------------- |
| `*.json`           | JSON-formatted audit or inspection outputs (IAM, network, ALB) |
| `*.md`             | Markdown summaries generated for human-readable reporting      |
| `*-inspection.log` | Text-based logs from post-deployment inspection tools          |

## Example Reports

- `alb-config.json`: Full ALB config with backend services, health checks, URL maps
- `iam-profiles.json`: IAM role bindings per service account
- `network-map.md`: Summary of VPC, subnets, routes, PSA settings

## Report Generators

| Script                                  | Output                                              |
| --------------------------------------- | --------------------------------------------------- |
| `scripts/manage/inspect-services.shell` | Load balancer JSON & text breakdown                 |
| `scripts/manage/profile-activity.shell` | IAM + role mapping report (enriched metadata)       |
| GitHub Actions `terraform-output` job   | Writes Terraform outputs to JSON for downstream use |

## DevSecOps Value

- 🔍 Passive observability for audit, review, and compliance validation
- 📁 Snapshot-based: all reports traceable to a specific deploy
- 🧾 Structured enough for machine parsing; readable enough for humans
- 🔐 Reports avoid secrets but reveal structure and IAM details

## Future Plans

-

---

*This README describes the purpose and layout of ******`reports/`****** as of April 1, 2025.*
