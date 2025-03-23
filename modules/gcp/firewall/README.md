# GCP Firewall Module

## Files
- `modules/gcp/firewall/firewall.tf`
- `modules/gcp/firewall/outputs.tf`
- `modules/gcp/firewall/variables.tf`

## Version
`Version: 0.1.0`

---

## Overview
This Terraform module defines and manages a series of **firewall rules for Google Cloud Platform (GCP)**, with the primary goal of protecting virtual machine infrastructure by tightly controlling ingress access. The firewall configurations are highly modular, secure, and environment-agnostic—designed to integrate seamlessly with broader cloud architectures, including compute and load balancer modules.

Firewall rules are crafted using inputs pulled dynamically from structured JSON sources (`allowed.json`) that define DevOps IP ranges, private network CIDRs, and GCP Console-related access points. These rules help enforce **zero-trust networking principles** while maintaining compatibility with modern access workflows like **Google Identity-Aware Proxy (IAP)**.

The module’s logic ensures all rules apply **only to tagged resources**, and that **unauthorized traffic is blocked by default**. It supports both production and sandbox environments, making it an essential piece in any secure GCP infrastructure.

---

## Core Features

### SSH Access (Restricted to Trusted IPs)
- Allows TCP port `22` only from select sources:
  - **DevOps engineers' public IPs**, stored in `devops_ips`
  - **Internal RFC1918 networks**, such as `10.0.0.0/8`, provided via `private_ips`
  - **Google Console and IAP** IP ranges stored in `console_ips`
- These rules only affect instances tagged with `ssh-access`, minimizing unnecessary exposure across the network
- Ideal for production environments with strict SSH controls and traceable access patterns

### SSH via IAP (Identity-Aware Proxy)
- Creates a separate rule specifically allowing SSH access via Google IAP
- Authorizes traffic originating from Google’s own IAP infrastructure (`console_ips`)
- Targets instances tagged with `ssh-access`, similar to the direct SSH rule
- Enables secure, identity-based administration from remote workstations or laptops without requiring a VPN

### HTTP & HTTPS Ingress
- Permits TCP ports `80` (HTTP) and `443` (HTTPS) from all source IPs (`0.0.0.0/0`)
- Intended for public-facing applications or services behind a **GCP HTTP(S) Load Balancer**
- Designed to support scalable backend services like those deployed through a regional MIG (Managed Instance Group)
- These rules attach to instances tagged with `http-server`, preserving isolation between compute roles

---

## Module Inputs

This module expects inputs for environmental awareness and to properly scope firewall behavior across deployment regions and access tiers:

| Variable       | Description                                                 | Type           | Required |
|----------------|-------------------------------------------------------------|----------------|----------|
| `region`       | The GCP region for regional context (may be used for logging or naming) | `string`     |       |
| `network`      | VPC network name or ID to which the firewall rules apply    | `string`       |       |
| `devops_ips`   | List of public IPs trusted for SSH access                   | `list(string)` |       |
| `private_ips`  | RFC1918 ranges for internal-only traffic                    | `list(string)` |       |
| `console_ips`  | GCP-owned IPs used by Console and Identity-Aware Proxy      | `list(string)` |       |

---

## Outputs

These outputs reflect the firewall module’s dynamic ingress control behavior and allow referencing source configurations elsewhere in your Terraform setup:

| Output        | Description                                      |
|---------------|--------------------------------------------------|
| `devops_ips`  | List of externally trusted IPs (DevOps access)   |
| `private_ips` | Private IP ranges used for intra-network traffic |
| `console_ips` | GCP IAP/Console ingress range reference          |

---

## Design Considerations

- **Principle of Least Privilege**: Default deny strategy with explicitly scoped allow rules
- **IAP & Console Compatibility**: Supports cloud-native access workflows without VPN dependency
- **Environment-Driven Behavior**: Source ranges are not hardcoded; they are imported from JSON
- **Network Segmentation by Tags**: Firewall rules only apply to instances with relevant tags (e.g., `ssh-access`, `http-server`)
- **Auditability**: All access control is driven by configuration files, making the setup easy to audit and change-tracked in source control
- **Integration-Ready**: Designed for tight coupling with modules that provision MIGs, load balancers, and private networks

---

## Use Case
This firewall module is suited for any deployment that requires:
- **Production-grade security policies**
- Fine-grained access control for internal services
- Identity-aware SSH access using IAP instead of public key sharing
- A reusable, auditable way to apply ingress policies using structured data inputs

### Example Scenarios:
- Locking down SSH access to backend instances within a Managed Instance Group
- Enabling HTTPS traffic to a global Load Balancer fronting web servers
- Using `allowed.json` to restrict environments based on user IP location or role

This module becomes even more powerful when used alongside:
- **Compute modules** that apply relevant `target_tags`
- **Networking modules** that define the VPC and subnets
- **Observability tools** (e.g., logging firewall access logs via GCP)

---

## Summary
This GCP firewall module provides secure, flexible, and modular ingress control for cloud-based virtual machines. It emphasizes zero-trust principles, integrates identity-aware SSH access, and ensures clear separation of environments using declarative inputs.

By tightly controlling access through dynamic configurations and supporting best practices for infrastructure as code (IaC), it serves as a foundational layer for secure GCP deployments across dev, staging, and production tiers.
