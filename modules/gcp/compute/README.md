# GCP Compute Module (Managed Instance Group)

## Files
- `modules/gcp/compute/compute.tf`
- `modules/gcp/compute/outputs.tf`
- `modules/gcp/compute/variables.tf`

## Version
`Version: 0.1.0`

---

## Overview
This Terraform module provisions a **regional Managed Instance Group (MIG)** within **Google Cloud Platform (GCP)**. It offers a scalable, production-ready compute layer ideal for workloads requiring load balancing, zone redundancy, and startup automation.

Rather than managing standalone VM instances, this module leverages GCP’s MIG architecture to simplify orchestration, enable zero-downtime scaling, and centralize instance configuration. It is fully integrated with a global Application Load Balancer (ALB), to which it forwards health-verified traffic.

With built-in support for automated provisioning, health monitoring, startup scripting, and consistent tagging, this module is designed to serve as the foundation for modern, cloud-native compute infrastructure.

---

## Core Features

### Managed Instance Group (MIG)
- **High Availability**: Distributes instances across all zones in the specified region for resilience against zonal outages
- **Unified Configuration**: All instances derive from a common instance template, ensuring consistent machine configuration
- **Elastic Scaling**: Number of VMs is controlled using the `instance_count` input, enabling horizontal scalability

### Instance Template
- Based on the official **Debian 11 image** from `debian-cloud`
- Executes a startup script (`scripts/setup-webserver.shell`) for initialization tasks (e.g., web server installation, logging agents)
- Attaches each instance to user-defined `network` and `subnetwork`, maintaining infrastructure consistency
- Adds structured tags for:
  - `ssh-access` — Enables secure shell access
  - `http-server` — Identifies instances for firewall rules or HTTP backends
  - `couchsurfing` — Custom application-specific tag

### Health Check
- Integrates a `google_compute_health_check` resource to monitor backend VM health
- Performs HTTP-level checks on port 80
- Customizable check and timeout intervals
- Enables ALB to automatically route traffic only to healthy instances

### Outputs
- `instance_type`: Reports the machine type (e.g., `e2-micro`, `n1-standard-1`)
- `web_servers_group`: Returns the managed instance group name to link in backend services
- `web_server_ip`: Reference to the IP group used for backend load balancer routing

---

## Module Inputs

| Variable           | Description                                                  | Type    | Required |
|--------------------|--------------------------------------------------------------|---------|----------|
| `region`           | GCP region where the MIG will be deployed                   | string  |       |
| `instance_count`   | Number of VM instances to launch in the group               | number  |       |
| `instance_type`    | VM type (e.g., `e2-micro`, `n1-standard-1`)                 | string  |       |
| `gcp_project_id`   | ID of the target GCP project                                | string  |       |
| `gcp_credentials`  | Base64-encoded service account key (sensitive)              | string  |       |
| `network`          | ID of the VPC network to connect the instances              | string  |       |
| `subnetwork`       | Subnetwork to which instances should attach                 | string  |       |

---

## Health Check Logic
The health check uses the native GCP resource `google_compute_health_check` to evaluate instance readiness. It performs simple HTTP GET requests to port 80 and expects an HTTP 200 OK response.

- If an instance fails consecutive checks, it is marked unhealthy and removed from rotation.
- Once it recovers, traffic is automatically resumed.
- This mechanism ensures uninterrupted service availability and reduces the risk of routing to non-functional backends.

---

## Design Considerations
- **Built for ALBs**: This module assumes traffic will be routed via a load balancer, not through public IPs
- **Zone Resilience**: MIGs handle automatic balancing across available zones
- **Security First**: Instances are private by default; no external IPs are provisioned
- **Startup Consistency**: Scripts provide idempotent configuration for predictable instance behavior
- **Cloud-Native Practices**: All compute provisioning follows Terraform best practices

---

## Deprecated Alternative (Commented Out)
For educational and migration purposes, the module retains a commented-out example of creating individual `google_compute_instance` resources directly. While functionally viable, this pattern lacks zone balancing, scalability, and automatic healing. Users are strongly encouraged to use MIGs in production environments.

---

## Advanced Usage Tips
- Combine with a **global HTTP(S) load balancer** for auto-scaling and internet routing
- Use the `web_servers_group` output to wire into `backend_service` blocks
- Reference `web_server_ip` in monitoring, diagnostics, or service mesh configuration
- Override `startup-script` path if customizing bootstrap logic across environments
- Integrate with **GCP Monitoring** for alerting based on health check performance

---

## Example Use Case
This module is ideal for deploying:
- Stateless web applications
- Scalable backend APIs
- HTTP application tiers
- Microservices behind a reverse proxy or gateway

It is commonly paired with:
- `networking` modules to provision VPC, subnet, and routes
- `firewall` modules to allow restricted ingress/egress traffic
- `load-balancer` modules to serve global HTTP traffic securely

---

## Summary
This GCP compute module offers a modern, robust, and production-ready architecture for deploying compute resources on Google Cloud. It makes full use of Managed Instance Groups to enable zone-aware scalability, integrates with health checks for high reliability, and follows security best practices by avoiding public IP exposure.

Its modular design, compatibility with broader Terraform stacks, and declarative infrastructure approach make it ideal for modern DevOps workflows and CI/CD automation pipelines.
