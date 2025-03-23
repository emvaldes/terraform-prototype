# GCP Load Balancer Module

## Files
- `modules/gcp/load_balancer/main.tf`
- `modules/gcp/load_balancer/outputs.tf`
- `modules/gcp/load_balancer/variables.tf`

## Version
`Version: 0.1.0`

---

## Overview
This Terraform module provisions a full-featured **Google Cloud Platform (GCP) HTTP Load Balancer (ALB)** configuration, designed to expose backend services to the internet with high availability, scalability, and observability. It assembles and connects all critical components required for global traffic routing across distributed compute instances, including:

- Health checks
- Backend services
- URL mapping
- HTTP proxy
- Global forwarding rule

The load balancer is fully decoupled from zone-specific instances and instead targets a regional instance group (MIG), making it well-suited for fault-tolerant deployments. It is a fundamental building block for deploying scalable web applications, APIs, or service gateways in production environments on GCP.

This module is designed to integrate with existing networking, firewall, and compute modules in the same Terraform stack, supporting highly modular infrastructure-as-code deployments with dynamic configuration.

---

## Core Features

### Health Check
- Provisions a `google_compute_health_check` that performs **HTTP checks** on port `80`
- Validates the responsiveness of backend instances using:
  - `check_interval_sec`: 5 seconds
  - `timeout_sec`: 5 seconds
- Ensures only healthy instances receive user traffic
- Can be reused across multiple backend services

### Backend Service
- Creates a `google_compute_backend_service` for registering instance groups
- Associates with the above health check
- Supports external traffic via the HTTP protocol
- Load balancing scheme is set to `EXTERNAL`, exposing it to the internet
- Connects to the **instance group** passed as a variable from your compute module
- Allows setting a connection timeout (`timeout_sec`) to ensure proper session behavior

### URL Map and Proxy
- Configures a `google_compute_url_map` as the routing engine
  - All incoming traffic is routed to the default backend
  - Ready for future extension to host-based or path-based routing
- Attaches the URL map to a `google_compute_target_http_proxy`
- Acts as the central logic point for request redirection

### Global Forwarding Rule
- Deploys a `google_compute_global_forwarding_rule`
  - Exposes port `80` on a globally accessible IP
  - Targets the HTTP proxy to route requests into the internal backend stack
  - Uses the `EXTERNAL` scheme for global reach
- Once deployed, the public IP becomes your HTTP endpoint

---

## Module Inputs

This module accepts inputs to control naming, connectivity, and backend attachment:

| Variable                     | Description                                             | Type     | Required |
|------------------------------|---------------------------------------------------------|----------|----------|
| `region`                     | Region used contextually for monitoring or integration | `string` |       |
| `network`                    | ID of the GCP VPC network                              | `string` |       |
| `subnetwork`                 | ID of the subnetwork                                   | `string` |       |
| `instance_group`            | Instance group used as backend target (MIG)            | `string` |       |
| `http_forwarding_rule_name` | Override name for the forwarding rule                  | `string` | Optional |
| `web_backend_service_name`  | Override name for backend service                      | `string` | Optional |
| `http_health_check_name`    | Override name for HTTP health check                    | `string` | Optional |

These variables allow teams to customize the deployment without modifying module internals, making the module suitable for different environments (e.g., `dev`, `staging`, `prod`).

---

## Outputs

| Output                      | Description                                                  |
|-----------------------------|--------------------------------------------------------------|
| `load_balancer_ip`          | Public IPv4 address of the global forwarding rule            |
| `http_forwarding_rule_name`| Name of the forwarding rule for reference and diagnostics   |
| `web_backend_service_name` | Name of the backend service assigned to the URL map         |
| `http_health_check_name`   | Health check resource name used for instance validation      |

These outputs can be referenced in other modules or CI/CD pipelines to monitor deployment state, publish DNS records, or test endpoint availability.

---

## Design Considerations

- **Scalability**: Designed to handle thousands of concurrent users with automatic health-based traffic management
- **Modularity**: Accepts backend targets and configuration from external modules
- **Global Reach**: The global forwarding rule ensures single-IP access regardless of region
- **Health-Oriented Routing**: Traffic is automatically removed from failing instances
- **Naming Conventions**: Optional overrides enable consistent naming across environments and CI/CD deployments
- **Cloud-Native Compliance**: Uses GCP-native load balancing components for best performance and integration

---

## Use Case
This module is best suited for:
- Hosting websites or APIs with high uptime requirements
- Exposing GCP-hosted applications to the internet securely
- Decoupling traffic entry from backend compute scaling
- Environments with auto-healing or autoscaled managed instance groups
- Teams managing infrastructure using modular Terraform design

Examples include:
- A web service running behind a MIG deployed with the compute module
- A regional API service balanced globally via the forwarding rule
- A public static application with URL routing control through `url_map`

---

## Extension Tips
- Add TLS support using `google_compute_target_https_proxy` and `ssl_certificate`
- Expand URL map to support path-based or host-based routing
- Chain multiple backends under different routes
- Integrate with Cloud CDN for caching at edge locations
- Combine with Terraform `locals` and `for_each` to support multiple services

---

## Summary
The GCP Load Balancer module is a powerful abstraction for deploying a production-ready HTTP load balancer using native GCP services. With support for modular integration, dynamic input overrides, and health-aware traffic routing, it is well-suited for cloud-native workloads requiring robust ingress control and high availability.

By combining components like `health_check`, `backend_service`, `url_map`, `proxy`, and `forwarding_rule`, the module offers complete control over public HTTP routing—whether for web applications, microservices, or APIs running across GCP infrastructure.
