# Terraform Module: GCP Load Balancer

**Version:** `0.1.0`

## Overview
This module provisions a global HTTP(S) Load Balancer in Google Cloud Platform (GCP) and binds it to a backend service powered by regional managed instance groups. It provides a production-grade public endpoint to receive internet traffic, distribute it across compute instances, and monitor service health through automated checks.

The load balancer supports high-availability, cross-regional backends (if enabled), and integration with compute, firewall, and DNS modules. It is typically deployed as the primary ingress point for stateless web applications, APIs, or test targets.

## Key Features
- Provisions a global external HTTP(S) Load Balancer
- Connects to backend instance groups using named ports
- Enables health checks, session affinity, and autoscaling support
- Outputs IP address and forwarding rule details for DNS mapping or validation
- Modular and reusable across staging, dev, and production environments

## Files
- `load_balancer.tf`: Core resource declarations (forwarding rule, backend service, URL map, proxy)
- `load_balancer.variables.tf`: Input variable declarations
- `load_balancer.outputs.tf`: Exposes IP address, backend name, and forwarding rule

## Inputs
| Variable               | Description                                                               |
|------------------------|---------------------------------------------------------------------------|
| `project_id`           | GCP project ID for resource ownership                                     |
| `region`               | Region where the backend instance group resides                          |
| `service_name`         | Logical name to use across all LB resources                              |
| `instance_group_name`  | Name of the managed instance group to attach                             |
| `named_ports`          | Named port(s) to associate with backend group (e.g., `http:80`)          |
| `backend_config`       | Optional backend policy (e.g., balancing mode, session affinity)         |
| `health_check_config`  | Parameters for HTTP(S) health checks (port, path, thresholds, etc.)      |

## Outputs
| Output                 | Description                                                               |
|------------------------|---------------------------------------------------------------------------|
| `load_balancer_ip`     | The external IP address assigned to the forwarding rule                  |
| `forwarding_rule_name` | The name of the forwarding rule used to route external traffic           |
| `backend_service_name` | The fully qualified name of the backend service attached to the MIG      |

## Integration
- The backend instance group must be pre-created via the `compute` module
- Health check IPs must be explicitly allowed via the `firewall` module:
  - `130.211.0.0/22`, `35.191.0.0/16` (GCP health check sources)
- IP output is used by test scripts (`main.py`, `run-stressload`) and external clients
- Interacts with CI/CD pipelines and DNS records for public exposure

## Design Considerations
- Uses global external HTTP(S) forwarding rule
- Requires backend service to register at least one healthy instance before routing traffic
- Named ports must be set identically in both the instance group and load balancer configs
- Stateless architecture preferred for backend compute (no session affinity unless explicitly needed)
- Supports path-based routing if extended via URL map definitions

## Use Cases
- Public access point for auto-scaled web servers
- Load testing or synthetic monitoring endpoints
- Integration with domain fronting, CDN caching, or edge security services

## Tips for Extension
- Add support for HTTPS with SSL certificates (managed or self-signed)
- Define URL maps with custom path matchers and backends
- Export DNS zone entries for automated domain binding
- Integrate monitoring with uptime checks and alert policies

## Security Considerations
- Ensure firewall rules explicitly allow health checker IPs
- Apply IAM roles carefully if using identity-bound backends
- Monitor and rotate SSL certs (if added)
- Review global service quotas for forwarding rules and IPs

## Usage Notes
- Create after compute instances and firewall rules
- Outputs should be registered with scripts and monitoring tools
- Validated automatically via stressload or pingback functions

## Summary
The `gcp/load_balancer` module provisions a scalable, global ingress layer for services hosted in GCP. It connects backend compute infrastructure to the internet using policy-driven traffic routing, health-aware load distribution, and secure external IPs. It is a core infrastructure gateway for high-performance web applications and CI-validated testing environments.

