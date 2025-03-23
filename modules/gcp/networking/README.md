# GCP Networking Module

## Files
- `modules/gcp/networking/networking.tf`
- `modules/gcp/networking/outputs.tf`
- `modules/gcp/networking/router.tf`
- `modules/gcp/networking/variables.tf`

## Version
`Version: 0.1.0`

---

## Overview
This Terraform module provisions essential **Google Cloud Platform (GCP) networking infrastructure** to support secure, modular, and internet-accessible cloud environments. It sets up a custom **Virtual Private Cloud (VPC)**, a **regional subnetwork**, and a **Cloud NAT gateway** backed by a **Cloud Router**—creating the core foundation needed to launch scalable, production-ready infrastructure.

The networking configuration separates concerns between public access and private cloud communications, enabling secure routing, minimal attack surface, and easy integration with managed instance groups, load balancers, or containerized workloads. By avoiding default GCP networks and instead deploying minimal, explicitly-defined networking resources, the module ensures full control and predictability across deployments.

It is especially well-suited for multi-environment (dev, staging, prod) setups where region-specific deployments and subnetting strategies are required.

---

## Core Features

### VPC Network
- Creates a custom, non-default VPC named `webapp-vpc`
- `auto_create_subnetworks` is disabled to prevent creation of default subnets
- Centralizes private networking for all compute and service modules
- Acts as a foundational network boundary within a GCP project
- Ready for peering, shared VPC, or hybrid connections as environments grow

### Subnetwork
- Configures a regional subnetwork named `webapp-subnet`
- Allocated CIDR block: `10.0.1.0/24` (customizable in future versions)
- Bound to the custom VPC and scoped to the user-defined `region`
- Subnet can be attached to compute instances, load balancer backends, or container clusters

### Cloud Router + NAT Gateway
- A `google_compute_router` is deployed in the specified region
- A `google_compute_router_nat` resource is created to:
  - Provide outbound internet access to instances without public IPs
  - Dynamically allocate NAT IPs via `AUTO_ONLY`
  - Apply NAT rules across **all subnets** in the VPC
  - Enable logging for **error-level NAT events**, aiding debugging and cost-efficient observability
- Prevents the need to assign or manage external IPs on compute resources while maintaining internet reachability

---

## Module Inputs

| Variable   | Description                                                      | Type     | Required |
|------------|------------------------------------------------------------------|----------|----------|
| `region`   | The GCP region where all networking resources are deployed       | `string` |       |

The region input allows the module to deploy region-scoped resources, which is critical for aligning with compute, database, or container workloads residing in the same region.

---

## Outputs

| Output           | Description                                             |
|------------------|---------------------------------------------------------|
| `region`         | Region used for network deployment                      |
| `vpc_network_id` | Fully qualified resource ID of the created VPC          |
| `subnet_id`      | Fully qualified resource ID of the created subnetwork   |

These outputs are intended for reference in dependent modules (e.g., compute, load balancer) that need to attach to the networking layer.

---

## Design Considerations
- **Security-First Posture**: No public IPs are assigned to instances by default, reducing exposure
- **Explicit Subnet Control**: IP ranges are defined manually to ensure consistency, predictability, and compatibility with service-level segmentation
- **Infrastructure Observability**: NAT is configured with `ERRORS_ONLY` logging to capture failures without generating excess log volume
- **Scalable by Design**: Built to be extended with additional subnets, firewall rules, or inter-region networking
- **Compatibility**: Fully compatible with GKE clusters, managed instance groups, and GCP internal load balancers

---

## Use Cases
This module can be used as the starting point for many different types of GCP projects:

- **Web application hosting**: Compute instances or container workloads behind a load balancer
- **Backend microservices**: Systems that require egress access but no public exposure
- **Private CI/CD environments**: Runners or agents needing outbound internet to fetch dependencies
- **Cloud-native hybrid networking**: Use as part of a shared VPC or peered setup to extend connectivity
- **Multi-module Terraform infrastructures**: Acts as the common network layer shared by other components

This module abstracts away boilerplate setup and enables developers to focus on application-layer infrastructure by taking care of VPC configuration, subnet setup, and NAT provisioning.

---

## Tips for Extension
- Add support for multiple subnets and IP CIDR ranges using `for_each`
- Integrate `google_compute_firewall` rules to control ingress and egress
- Attach routes or VPN tunnels for hybrid workloads
- Define output locals for DNS resolution or service discovery

---

## Summary
The GCP Networking module serves as a modular, reusable layer for provisioning secure and scalable VPC-based networking in Google Cloud. It ensures that workloads are logically isolated, private by default, and equipped with outbound connectivity through NAT—all while minimizing operational complexity.

As a core dependency in larger infrastructure deployments, this module supports best practices in cloud networking and provides a solid foundation for deploying robust application architectures that demand high security, flexibility, and reliability.
