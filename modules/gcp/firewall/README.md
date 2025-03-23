# Terraform Module: GCP Firewall

**Version:** `0.1.0`

## Overview
This module provisions and manages firewall rules within a GCP Virtual Private Cloud (VPC) to control ingress and egress access to resources deployed via Terraform. It supports dynamic CIDR-based allowlists, service port restrictions, and intra-project communication tags for managed instance groups and Cloud Functions.

It is designed to enforce a **security-first posture** with a minimal trust surface, allowing only explicitly defined traffic from known sources. Rules are automatically generated based on configuration files and target environments, making them adaptable across dev, staging, and production.

## Key Features
- Restricts ingress traffic by IP range and port
- Defines firewall rules by instance network tags
- Applies GCP-recommended rules for health checks and load balancer probes
- Supports logging configuration per rule
- Exposes all rule names and tags for downstream use
- Centralized rule logic via `configs/allowed.json`
- Supports Identity-Aware Proxy (IAP) access for secure SSH administration when configured

## Files
- `firewall.tf`: Core firewall rule resources
- `firewall.variables.tf`: Input definitions
- `firewall.outputs.tf`: Output exports (tags, rule IDs)

## Inputs
| Variable               | Description                                                          |
|------------------------|----------------------------------------------------------------------|
| `project_id`           | GCP project in which rules are deployed                              |
| `network`              | Name of the VPC to attach firewall rules                             |
| `region`               | Target region (used for tag mapping consistency)                     |
| `allowed_ssh_cidrs`    | List of IP CIDRs allowed for SSH access                              |
| `allowed_http_cidrs`   | List of IP CIDRs allowed for HTTP/HTTPS access                       |
| `internal_ranges`      | List of internal VPC CIDRs allowed for intra-service communication   |
| `tag_selectors`        | Map of instance/service tags to associate with rules                 |
| `log_config`           | Optional logging configuration (`true`, `false`, or detail map)      |

> Note: All IP range inputs (e.g., `allowed_http_cidrs`, `allowed_ssh_cidrs`, `internal_ranges`) are expected to come from centrally maintained configuration files like `configs/allowed.json`.

## Outputs
| Output                | Description                                                 |
|-----------------------|-------------------------------------------------------------|
| `firewall_rule_ids`   | List of created GCP firewall rule resource names            |
| `http_tags`           | Network tags required to receive HTTP/S traffic             |
| `ssh_tags`            | Tags required to receive SSH access                         |

## Integration
- Used by `gcp/compute` to tag instance templates for rule targeting
- Combined with `configs/allowed.json` for external allowlist definitions
- Required by `load_balancer` to enable backend health checks
- Coordinates with NAT/VPC modules to restrict egress and define east-west traffic flow

## Design Considerations
- **Principle of Least Privilege**: Default deny strategy with explicitly scoped allow rules
- **Rule Reuse**: Multiple services can share a tag for scalable rule application
- **Logging**: Use selectively to minimize verbosity while maintaining observability
- **Tag-based Control**: Promotes modular isolation and access scoping
- **Default Behavior**: All environments assume implicit deny unless explicitly overridden

## Use Cases
- Enable web traffic to instances (`allow-http`, `allow-https`)
- Restrict SSH access to corporate or jumpbox IPs only
- Permit load balancer and health check traffic from GCP's internal IPs
- Define app-tier-to-data-tier internal traffic
- Apply common ingress rules across environments by tag reuse

## Tips for Extension
- Add egress control (currently focused on ingress only)
- Define protocol-specific rules (e.g., ICMP, UDP, etc.)
- Generate rules via `for_each` keyed on services or environments
- Integrate with `gcloud` logging exports for long-term analytics

## Security Considerations
- Always restrict SSH to trusted IPs; avoid `0.0.0.0/0`
- Use internal-only tags for services that don't need internet exposure
- Avoid overlapping rules; evaluate priorities to ensure deterministic behavior
- Firewall rules are stateless in GCP—ensure both directions are covered where needed

## Usage Notes
- Create after networking and before compute resources
- Network tags must match exactly across rule and instance templates
- Consider staging rules separately by environment or application type

## Summary
The `gcp/firewall` module provides centralized, declarative control over GCP network access. It enforces secure ingress policies based on CIDRs, ports, and service tags, while remaining composable and environment-aware. As a network security boundary, it underpins the reliability and safety of all downstream cloud infrastructure.

