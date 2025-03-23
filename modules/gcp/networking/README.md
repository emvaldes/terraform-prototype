# Terraform Module: GCP Networking

**Version:** `0.1.0`

## Overview
This module provisions and configures the core network topology in Google Cloud Platform (GCP), including VPC creation, subnet provisioning, NAT gateway setup, and Cloud Router configuration. It acts as the foundational layer upon which all compute, load balancing, and function-based infrastructure components rely for connectivity, segmentation, and egress.

The networking configuration separates concerns between public access and private cloud communications, enabling secure routing, minimal attack surface, and easy integration with managed instance groups, load balancers, or containerized workloads. By avoiding default GCP networks and instead deploying minimal, explicitly-defined networking resources, the module ensures full control and predictability across deployments.

It is especially well-suited for multi-environment (dev, staging, prod) setups where region-specific deployments and subnetting strategies are required.

## Key Features
- Creates custom-mode VPCs with named subnets per environment
- Configurable CIDR blocks via JSON configuration files (`targets/*.json`)
- Enables NAT gateways using Google Cloud Router for controlled egress
- Supports Private Service Access (PSA) for internal API consumption (e.g., Cloud SQL, Artifact Registry) *(optional and disabled by default)*
- Outputs core identifiers and self-links required by dependent modules
- Avoids default GCP subnets and public IP exposure
- NAT configured using dynamic IPs (mode subject to actual implementation)
- Built for extensibility: supports peering, shared VPCs, and VPN tunnels

## Files
- `networking.tf`: Declares VPC and subnet resources
- `networking.router.tf`: Handles NAT IP allocation and router definitions
- `networking.variables.tf`: Defines inputs such as `vpc_name`, `region`, `cidr_blocks`, `nat_enabled`
- `networking.outputs.tf`: Exposes networking artifacts for cross-module consumption

> ⚠️ `networking.manage.tf` has been deprecated or removed in recent iterations.

## Inputs
| Variable         | Description                                                             |
|------------------|-------------------------------------------------------------------------|
| `vpc_name`        | Logical name for the custom VPC                                        |
| `region`          | Region in which subnets and routers are created                        |
| `cidr_blocks`     | Mapping of subnet names to CIDR ranges                                 |
| `enable_psa`      | Boolean to enable Private Service Access (optional; defaults to false) |
| `nat_enabled`     | Boolean to provision NAT for egress connectivity                       |
| `project_id`      | ID of the GCP project to which all resources are assigned              |

## Outputs
| Output            | Description                                                             |
|-------------------|-------------------------------------------------------------------------|
| `vpc_self_link`   | Fully qualified self-link of the VPC                                   |
| `subnet_names`    | List of all provisioned subnet names                                    |
| `nat_ip_list`     | List of static or auto-allocated external IPs for NAT                  |
| `router_name`     | Identifier of the Cloud Router managing dynamic NAT translation        |

## Integration
- Referenced by the `compute`, `load_balancer`, and `firewall` modules for subnet lookups and route bindings
- Used by `cloud_function` if VPC Connector is configured (for private network egress)
- Inputs sourced from `configs/targets/*.json` and `configs/policies.json`
- Outputs feed directly into routing logic for autoscaling groups and ALB backend services
- Subnet names are passed to instance templates for NIC association

## Design Considerations
- **Security-First Posture**: Instances do not receive public IPs by default
- **Explicit Subnet Control**: CIDRs are user-defined to ensure deterministic layout
- **Infrastructure Observability**: NAT logging optional but recommended in production (e.g., `ERRORS_ONLY`)
- **Scalable by Design**: Additional subnets, VPC peerings, and multi-region deployments are supported
- **Compatibility**: Built for integration with MIGs, GKE clusters, and ILBs

## Use Cases
- Web app backends with private instance groups
- Backend microservices requiring outbound egress only
- CI/CD workers that fetch external packages but stay unexposed
- Internal APIs or services using PSA (if enabled) to avoid external GCP endpoints
- Shared VPC or peered-network architectures

## Tips for Extension
- Use `for_each` to manage multiple subnets or IP tiers
- Integrate firewall modules for layered ingress/egress rules
- Attach routes, peering, or VPN tunnels for hybrid networking
- Extend output locals to support DNS integration or monitoring hooks

## Security Considerations
- Subnets can enable VPC Flow Logs for enhanced monitoring
- PSA should be enabled explicitly and with care depending on service needs
- NAT IPs can be restricted via firewall rules to avoid open internet routing
- Supports separation of DMZ, app, and data tiers through multiple CIDR declarations

## Usage Notes
- Create this module before provisioning compute or load balancer resources
- CIDR ranges should be managed in a central policy file to prevent collisions
- VPC names should remain globally unique within the project to support peering
- NAT gateways are required for outbound internet access from private instances

## Summary
The `gcp/networking` module provides a clean, policy-driven abstraction around GCP’s networking stack. It serves as the backbone of all compute-driven workloads by enabling controlled routing, private access to Google APIs, and public egress via NAT. It supports multi-environment flexibility, minimal attack surface design, and extensible architecture for scaling teams and workloads.
