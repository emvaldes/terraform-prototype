# Terraform Module: GCP Compute

**Version:** `0.1.0`

## Overview
This module provisions a horizontally scalable compute infrastructure using Google Cloud Platform (GCP) Managed Instance Groups (MIGs). It leverages instance templates and autoscaling logic to provide resilient, self-healing, and environment-specific virtual machine pools. The module is designed to act as the core processing layer for application backends, batch workloads, or testbed environments.

Rather than managing standalone VM instances, this module uses GCP's native MIG architecture to centralize instance configuration, simplify scaling, and ensure high availability. It is fully integrated with other Terraform-managed components including load balancers, VPCs, firewall rules, IAM profiles, and startup scripts, making it a foundational building block for modern cloud-native deployments.

## Key Features
- Regional managed instance groups with automatic failover and zonal distribution
- Configurable launch templates with support for startup scripts and metadata injection
- Auto-healing and autoscaling based on CPU utilization and instance count thresholds
- Flexible machine sizing, disk provisioning, and network configuration
- Full output of group names, template IDs, autoscaler state, and tag metadata for chaining
- Optional HTTP health check to determine instance readiness and support backend load balancing

## Files
- `compute.tf`: MIG and instance template declarations, autoscaler configuration
- `compute.variables.tf`: Inputs for VM size, disk, identity, scaling, and startup behavior
- `compute.outputs.tf`: Outputs resource identifiers, template state, and network tags

## Inputs
| Variable                 | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `project_id`             | GCP project to deploy the resources into                                    |
| `region`                 | Region for the regional MIG                                                 |
| `vpc_network`            | Self-link or name of the VPC network                                        |
| `subnetwork`             | Self-link or name of the subnetwork                                         |
| `machine_type`           | VM type for each instance (e.g., `e2-medium`)                               |
| `disk_size_gb`           | Size of the boot disk in gigabytes                                          |
| `image_family`           | OS image family (e.g., `debian-11`)                                         |
| `image_project`          | Project that owns the image (e.g., `debian-cloud`)                          |
| `instance_tags`          | List of tags for firewall/load balancing                                    |
| `startup_script`         | Path or inline content of startup script to initialize VMs                  |
| `service_account`        | Service account email for IAM bindings                                     |
| `scopes`                 | OAuth scopes for accessing GCP services                                     |
| `min_replicas`           | Minimum number of VMs in the MIG                                            |
| `max_replicas`           | Maximum number of VMs in the MIG                                            |
| `target_cpu_utilization` | CPU target for autoscaler to add/remove instances                          |

> 🔧 **Note:** Default startup script is typically located at `scripts/configure/apache-webserver.shell`.

## Outputs
| Output                  | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `instance_group_name`   | Name of the managed instance group                                           |
| `instance_template_id`  | ID of the launch template                                                    |
| `instance_tags`         | Tags applied to instances for network/firewall use                          |
| `auto_scaler_name`      | Name of the autoscaler resource                                              |

## Integration
- Consumed by the `load_balancer` module as backend group input
- Requires VPC/subnet from the `networking` module for network interface config
- Uses IAM profiles provisioned by the `profiles` module
- Expects tags to match ingress rules defined in the `firewall` module
- Startup script typically references files under `scripts/configure/`
- Can participate in health checks used by ALBs to route traffic to healthy backends

## Design Considerations
- Designed for stateless apps — no persistent storage between reboots
- Startup script must be idempotent and include full bootstrapping logic
- Network tags act as access gates; tagging mismatch causes firewall failure
- Auto-scaling is reactive: scale up happens after utilization breach
- Health check failures temporarily remove VMs from the backend until recovery
- VMs operate under a shared regional policy, not zonal

> ⚠️ **Note:** This module intentionally excludes standalone `google_compute_instance` resources in favor of MIGs for high availability and operational consistency.

## Use Cases
- Auto-scaled web server fleets behind an HTTP(S) load balancer
- Ephemeral CI/CD test runners
- Internal API clusters requiring tag-isolated routing
- Application nodes participating in distributed systems

## Extension Tips
- Attach persistent disks or local SSDs if data retention is required
- Use multiple instance templates with `for_each` for tiered services
- Incorporate monitoring/alerting agents in the startup script
- Adjust scaling policies for off-hours cost reduction or predictive load
- Integrate with Cloud Armor for perimeter protection

## Security Considerations
- Always assign minimal required scopes and a tightly-bound service account
- Use hardened base images and verified startup script sources
- Enable VPC Flow Logs and audit logs for instance group
- Regularly rotate service accounts and validate IAM bindings

## Summary
The `gcp/compute` module provides a robust, autoscaling compute tier built on GCP’s managed instance group infrastructure. By standardizing on declarative launch templates, network bindings, identity models, and lifecycle automation, this module serves as a secure and scalable building block for cloud-native applications, testing environments, and backend workloads.

