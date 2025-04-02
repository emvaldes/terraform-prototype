# Directory: scripts/

## Overview

The `scripts/` directory contains automation utilities that extend the Terraform infrastructure with inspection, packaging, introspection, and stress-testing capabilities. These tools are used in both local and CI/CD pipelines to maintain secure, observable, and self-documenting infrastructure.

Scripts are categorized by function and referenced in `project.json` under the `scripts` object.

## Structure

| Path | Purpose |
|------|---------|
| `scripts/manage/` | Admin tasks: packaging functions, inspecting IAM, tracking services |
| `scripts/stressload/` | Stress-test HTTP endpoints using Cloud Functions or local Python |
| `scripts/packages/` | Output location for generated `.zip` archives (Cloud Functions) |

## Key Scripts

### `scripts/manage/package-functions.shell`
- 📦 Packages Cloud Function code from `scripts/stressload/webservers/`
- Builds `function_config.json` using Terraform outputs
- Verifies archive contents and deploy readiness

### `scripts/manage/profile-activity.shell`
- 🔍 Merges IAM activity inspection (project-level + Terraform-managed)
- Displays service account roles and permissions with profile tagging

### `scripts/stressload/webservers/main.py`
- 🚀 GCP-compatible HTTP-triggered Cloud Function
- Loads `config.json` for test parameters (target URL, duration, ramp-up)
- Emits logs to Cloud Logging

### `scripts/stressload/webservers/requirements.txt`
- Declares Python dependencies for stressload function
- Minimal set to support `requests` and `logging`

## DevSecOps Value

- ✅ Automation-first: all scripts are CI-compatible and repeatable
- 🔐 No secrets hardcoded: function config injected via `config.json`
- 🔄 Modular utilities that decouple logic from infrastructure
- 📜 All scripts follow strict naming, versioning, and logging standards

## Future Plans

- [ ] Add `scripts/manage/test-connectivity.shell` for live TCP/HTTP probes
- [ ] Build `scripts/manage/gen-docs.shell` to auto-document modules and configs
- [ ] Extend `main.py` to support AWS Lambda and Azure Functions
- [ ] Support tracing and service mesh integration (Jaeger, OpenTelemetry)

---

```bash
$ terraform apply ;
```

```hcl
module.compute.data.google_compute_zones.available: Reading...
module.compute.data.google_compute_zones.available: Read complete after 0s [id=projects/static-lead-454601-q1/regions/us-west2]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.cloud_function.google_cloudfunctions2_function.cloud_function will be created
  + resource "google_cloudfunctions2_function" "cloud_function" {
      + description      = "Stub Cloud Function for stress testing framework"
      + effective_labels = {
          + "goog-terraform-provisioned" = "true"
        }
      + environment      = (known after apply)
      + id               = (known after apply)
      + location         = "us-west2"
      + name             = "dev--webapp-stress-tester"
      + project          = "static-lead-454601-q1"
      + state            = (known after apply)
      + terraform_labels = {
          + "goog-terraform-provisioned" = "true"
        }
      + update_time      = (known after apply)
      + url              = (known after apply)

      + build_config {
          + build                 = (known after apply)
          + docker_repository     = (known after apply)
          + entry_point           = "main"
          + environment_variables = (known after apply)
          + runtime               = "python311"
          + service_account       = (known after apply)

          + automatic_update_policy (known after apply)

          + source {
              + storage_source {
                  + bucket     = "dev--cloud-function-bucket"
                  + generation = (known after apply)
                  + object     = "dev--stressload-webservers.zip"
                }
            }
        }

      + service_config {
          + all_traffic_on_latest_revision   = true
          + available_cpu                    = (known after apply)
          + available_memory                 = "256M"
          + environment_variables            = {
              + "TARGET_URL" = null
            }
          + gcf_uri                          = (known after apply)
          + ingress_settings                 = "ALLOW_ALL"
          + max_instance_count               = (known after apply)
          + max_instance_request_concurrency = (known after apply)
          + service                          = (known after apply)
          + service_account_email            = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
          + timeout_seconds                  = 60
          + uri                              = (known after apply)
        }
    }

  # module.cloud_function.google_cloudfunctions2_function_iam_member.invoker will be created
  + resource "google_cloudfunctions2_function_iam_member" "invoker" {
      + cloud_function = "dev--webapp-stress-tester"
      + etag           = (known after apply)
      + id             = (known after apply)
      + location       = "us-west2"
      + member         = "allUsers"
      + project        = "static-lead-454601-q1"
      + role           = "roles/cloudfunctions.invoker"
    }

  # module.cloud_function.google_storage_bucket.function_bucket will be created
  + resource "google_storage_bucket" "function_bucket" {
      + effective_labels            = {
          + "goog-terraform-provisioned" = "true"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "US-WEST2"
      + name                        = "dev--cloud-function-bucket"
      + project                     = (known after apply)
      + project_number              = (known after apply)
      + public_access_prevention    = (known after apply)
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = {
          + "goog-terraform-provisioned" = "true"
        }
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)

      + soft_delete_policy (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # module.cloud_function.google_storage_bucket_object.function_archive will be created
  + resource "google_storage_bucket_object" "function_archive" {
      + bucket         = "dev--cloud-function-bucket"
      + content        = (sensitive value)
      + content_type   = (known after apply)
      + crc32c         = (known after apply)
      + detect_md5hash = "different hash"
      + generation     = (known after apply)
      + id             = (known after apply)
      + kms_key_name   = (known after apply)
      + md5hash        = (known after apply)
      + media_link     = (known after apply)
      + name           = "dev--stressload-webservers.zip"
      + output_name    = (known after apply)
      + self_link      = (known after apply)
      + source         = "./packages/stressload-webservers.zip"
      + storage_class  = (known after apply)
    }

  # module.compute.google_compute_health_check.http will be created
  + resource "google_compute_health_check" "http" {
      + check_interval_sec  = 5
      + creation_timestamp  = (known after apply)
      + healthy_threshold   = 2
      + id                  = (known after apply)
      + name                = "dev--http-health-check-us-west2"
      + project             = "static-lead-454601-q1"
      + self_link           = (known after apply)
      + timeout_sec         = 5
      + type                = (known after apply)
      + unhealthy_threshold = 2

      + http_health_check {
          + port         = 80
          + proxy_header = "NONE"
          + request_path = "/"
        }

      + log_config (known after apply)
    }

  # module.compute.google_compute_instance_template.web_server will be created
  + resource "google_compute_instance_template" "web_server" {
      + can_ip_forward       = false
      + creation_timestamp   = (known after apply)
      + effective_labels     = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                   = (known after apply)
      + machine_type         = "e2-micro"
      + metadata             = {
          + "startup-script" = <<-EOT
                #!/bin/bash
                
                # File: ./scripts/configure/apache-webserver.shell
                # Version: 0.1.0
                
                # Update package lists
                sudo apt update -y;
                
                # Install Apache web server
                sudo apt install -y apache2;
                
                # Start and enable Apache
                sudo systemctl start apache2;
                sudo systemctl enable apache2;
                
                # Create a simple HTML page to verify the instance is running
                echo -e "<h1>Server $(hostname) is running behind ALB</h1>" \
                   | sudo tee /var/www/html/index.html;
            EOT
        }
      + metadata_fingerprint = (known after apply)
      + name                 = (known after apply)
      + name_prefix          = "dev--web-server-template--"
      + project              = "static-lead-454601-q1"
      + region               = "us-west2"
      + self_link            = (known after apply)
      + self_link_unique     = (known after apply)
      + tags                 = [
          + "http-server",
          + "ssh-access",
        ]
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
          + "goog-terraform-provisioned" = "true"
        }

      + confidential_instance_config (known after apply)

      + disk {
          + auto_delete            = true
          + boot                   = true
          + device_name            = (known after apply)
          + disk_size_gb           = (known after apply)
          + disk_type              = (known after apply)
          + interface              = (known after apply)
          + mode                   = (known after apply)
          + provisioned_iops       = (known after apply)
          + provisioned_throughput = (known after apply)
          + source_image           = "debian-cloud/debian-11"
          + type                   = (known after apply)
        }

      + network_interface {
          + internal_ipv6_prefix_length = (known after apply)
          + ipv6_access_type            = (known after apply)
          + ipv6_address                = (known after apply)
          + name                        = (known after apply)
          + network                     = (known after apply)
          + stack_type                  = (known after apply)
          + subnetwork                  = (known after apply)
          + subnetwork_project          = (known after apply)
        }

      + scheduling (known after apply)
    }

  # module.compute.google_compute_region_autoscaler.web_autoscaler will be created
  + resource "google_compute_region_autoscaler" "web_autoscaler" {
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "dev--web-autoscaling"
      + project            = "static-lead-454601-q1"
      + region             = "us-west2"
      + self_link          = (known after apply)
      + target             = (known after apply)

      + autoscaling_policy {
          + cooldown_period = 60
          + max_replicas    = 3
          + min_replicas    = 1
          + mode            = "ON"

          + cpu_utilization {
              + predictive_method = "NONE"
              + target            = 0.6
            }
        }
    }

  # module.compute.google_compute_region_instance_group_manager.web_servers will be created
  + resource "google_compute_region_instance_group_manager" "web_servers" {
      + base_instance_name               = "dev--web-server"
      + creation_timestamp               = (known after apply)
      + distribution_policy_target_shape = (known after apply)
      + distribution_policy_zones        = [
          + "us-west2-a",
          + "us-west2-b",
          + "us-west2-c",
        ]
      + fingerprint                      = (known after apply)
      + id                               = (known after apply)
      + instance_group                   = (known after apply)
      + instance_group_manager_id        = (known after apply)
      + list_managed_instances_results   = "PAGELESS"
      + name                             = "dev--web-servers-group"
      + project                          = "static-lead-454601-q1"
      + region                           = "us-west2"
      + self_link                        = (known after apply)
      + status                           = (known after apply)
      + target_size                      = 1
      + target_stopped_size              = (known after apply)
      + target_suspended_size            = (known after apply)
      + wait_for_instances               = false
      + wait_for_instances_status        = "STABLE"

      + instance_lifecycle_policy (known after apply)

      + standby_policy (known after apply)

      + update_policy (known after apply)

      + version {
          + instance_template = (known after apply)
        }
    }

  # module.firewall.google_compute_firewall.allow_http_https will be created
  + resource "google_compute_firewall" "allow_http_https" {
      + creation_timestamp = (known after apply)
      + destination_ranges = (known after apply)
      + direction          = (known after apply)
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "dev--allow-http-https"
      + network            = (known after apply)
      + priority           = 1000
      + project            = "static-lead-454601-q1"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]

      + allow {
          + ports    = [
              + "80",
              + "443",
            ]
          + protocol = "tcp"
        }
    }

  # module.firewall.google_compute_firewall.allow_ssh will be created
  + resource "google_compute_firewall" "allow_ssh" {
      + creation_timestamp = (known after apply)
      + destination_ranges = (known after apply)
      + direction          = (known after apply)
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "dev--allow-ssh-restricted"
      + network            = (known after apply)
      + priority           = 1000
      + project            = "static-lead-454601-q1"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "10.0.0.0/8",
          + "35.235.240.0/20",
          + "68.109.187.94",
        ]
      + target_tags        = [
          + "ssh-access",
        ]

      + allow {
          + ports    = [
              + "22",
            ]
          + protocol = "tcp"
        }
    }

  # module.firewall.google_compute_firewall.allow_ssh_iap will be created
  + resource "google_compute_firewall" "allow_ssh_iap" {
      + creation_timestamp = (known after apply)
      + destination_ranges = (known after apply)
      + direction          = (known after apply)
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "dev--allow-ssh-iap"
      + network            = (known after apply)
      + priority           = 1000
      + project            = "static-lead-454601-q1"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "35.235.240.0/20",
        ]
      + target_tags        = [
          + "ssh-access",
        ]

      + allow {
          + ports    = [
              + "22",
            ]
          + protocol = "tcp"
        }
    }

  # module.load_balancer.google_compute_backend_service.web_backend will be created
  + resource "google_compute_backend_service" "web_backend" {
      + connection_draining_timeout_sec = 300
      + creation_timestamp              = (known after apply)
      + fingerprint                     = (known after apply)
      + generated_id                    = (known after apply)
      + health_checks                   = (known after apply)
      + id                              = (known after apply)
      + load_balancing_scheme           = "EXTERNAL"
      + name                            = "dev--web-backend-service"
      + port_name                       = (known after apply)
      + project                         = "static-lead-454601-q1"
      + protocol                        = "HTTP"
      + self_link                       = (known after apply)
      + session_affinity                = (known after apply)
      + timeout_sec                     = 30

      + backend {
          + balancing_mode               = "UTILIZATION"
          + capacity_scaler              = 1
          + group                        = (known after apply)
          + max_connections              = (known after apply)
          + max_connections_per_endpoint = (known after apply)
          + max_connections_per_instance = (known after apply)
          + max_rate                     = (known after apply)
          + max_rate_per_endpoint        = (known after apply)
          + max_rate_per_instance        = (known after apply)
          + max_utilization              = (known after apply)
            # (1 unchanged attribute hidden)
        }

      + cdn_policy (known after apply)

      + iap (known after apply)

      + log_config (known after apply)
    }

  # module.load_balancer.google_compute_global_forwarding_rule.http will be created
  + resource "google_compute_global_forwarding_rule" "http" {
      + base_forwarding_rule  = (known after apply)
      + effective_labels      = (known after apply)
      + forwarding_rule_id    = (known after apply)
      + id                    = (known after apply)
      + ip_address            = (known after apply)
      + ip_protocol           = (known after apply)
      + label_fingerprint     = (known after apply)
      + load_balancing_scheme = "EXTERNAL"
      + name                  = "dev--http-forwarding-rule"
      + network               = (known after apply)
      + network_tier          = (known after apply)
      + port_range            = "80"
      + project               = "static-lead-454601-q1"
      + psc_connection_id     = (known after apply)
      + psc_connection_status = (known after apply)
      + self_link             = (known after apply)
      + subnetwork            = (known after apply)
      + target                = (known after apply)
      + terraform_labels      = (known after apply)

      + service_directory_registrations (known after apply)
    }

  # module.load_balancer.google_compute_health_check.http will be created
  + resource "google_compute_health_check" "http" {
      + check_interval_sec  = 5
      + creation_timestamp  = (known after apply)
      + healthy_threshold   = 2
      + id                  = (known after apply)
      + name                = "dev--http-health-check"
      + project             = "static-lead-454601-q1"
      + self_link           = (known after apply)
      + timeout_sec         = 5
      + type                = (known after apply)
      + unhealthy_threshold = 2

      + http_health_check {
          + port         = 80
          + proxy_header = "NONE"
          + request_path = "/"
        }

      + log_config (known after apply)
    }

  # module.load_balancer.google_compute_target_http_proxy.default will be created
  + resource "google_compute_target_http_proxy" "default" {
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "dev--web-http-proxy"
      + project            = "static-lead-454601-q1"
      + proxy_bind         = (known after apply)
      + proxy_id           = (known after apply)
      + self_link          = (known after apply)
      + url_map            = (known after apply)
    }

  # module.load_balancer.google_compute_url_map.default will be created
  + resource "google_compute_url_map" "default" {
      + creation_timestamp = (known after apply)
      + default_service    = (known after apply)
      + fingerprint        = (known after apply)
      + id                 = (known after apply)
      + map_id             = (known after apply)
      + name               = "dev--web-url-map"
      + project            = "static-lead-454601-q1"
      + self_link          = (known after apply)
    }

  # module.networking.google_compute_global_address.cloudsql_psa_range will be created
  + resource "google_compute_global_address" "cloudsql_psa_range" {
      + address            = (known after apply)
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "dev--cloudsql-psa-range"
      + network            = (known after apply)
      + prefix_length      = 16
      + project            = "static-lead-454601-q1"
      + purpose            = "VPC_PEERING"
      + self_link          = (known after apply)
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
    }

  # module.networking.google_compute_network.vpc_network will be created
  + resource "google_compute_network" "vpc_network" {
      + auto_create_subnetworks                   = false
      + bgp_always_compare_med                    = (known after apply)
      + bgp_best_path_selection_mode              = (known after apply)
      + bgp_inter_region_cost                     = (known after apply)
      + delete_default_routes_on_create           = false
      + gateway_ipv4                              = (known after apply)
      + id                                        = (known after apply)
      + internal_ipv6_range                       = (known after apply)
      + mtu                                       = (known after apply)
      + name                                      = "dev--webapp-vpc"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + network_id                                = (known after apply)
      + numeric_id                                = (known after apply)
      + project                                   = "static-lead-454601-q1"
      + routing_mode                              = (known after apply)
      + self_link                                 = (known after apply)
    }

  # module.networking.google_compute_router.nat_router will be created
  + resource "google_compute_router" "nat_router" {
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "dev--webapp-router"
      + network            = (known after apply)
      + project            = "static-lead-454601-q1"
      + region             = "us-west2"
      + self_link          = (known after apply)
    }

  # module.networking.google_compute_router_nat.nat_config will be created
  + resource "google_compute_router_nat" "nat_config" {
      + auto_network_tier                   = (known after apply)
      + drain_nat_ips                       = (known after apply)
      + enable_dynamic_port_allocation      = (known after apply)
      + enable_endpoint_independent_mapping = true
      + endpoint_types                      = (known after apply)
      + icmp_idle_timeout_sec               = 30
      + id                                  = (known after apply)
      + min_ports_per_vm                    = (known after apply)
      + name                                = "dev--webapp-nat-config"
      + nat_ip_allocate_option              = "AUTO_ONLY"
      + nat_ips                             = (known after apply)
      + project                             = "static-lead-454601-q1"
      + region                              = "us-west2"
      + router                              = "dev--webapp-router"
      + source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
      + tcp_established_idle_timeout_sec    = 1200
      + tcp_time_wait_timeout_sec           = 120
      + tcp_transitory_idle_timeout_sec     = 30
      + udp_idle_timeout_sec                = 30

      + log_config {
          + enable = true
          + filter = "ERRORS_ONLY"
        }
    }

  # module.networking.google_compute_subnetwork.subnet will be created
  + resource "google_compute_subnetwork" "subnet" {
      + creation_timestamp         = (known after apply)
      + enable_flow_logs           = (known after apply)
      + external_ipv6_prefix       = (known after apply)
      + fingerprint                = (known after apply)
      + gateway_address            = (known after apply)
      + id                         = (known after apply)
      + internal_ipv6_prefix       = (known after apply)
      + ip_cidr_range              = "10.100.0.0/24"
      + ipv6_cidr_range            = (known after apply)
      + ipv6_gce_endpoint          = (known after apply)
      + name                       = "dev--webapp-subnet"
      + network                    = (known after apply)
      + private_ip_google_access   = true
      + private_ipv6_google_access = (known after apply)
      + project                    = "static-lead-454601-q1"
      + purpose                    = (known after apply)
      + region                     = "us-west2"
      + self_link                  = (known after apply)
      + stack_type                 = (known after apply)
      + state                      = (known after apply)
      + subnetwork_id              = (known after apply)

      + secondary_ip_range (known after apply)
    }

  # module.networking.google_project_service.servicenetworking will be created
  + resource "google_project_service" "servicenetworking" {
      + disable_on_destroy = true
      + id                 = (known after apply)
      + project            = "static-lead-454601-q1"
      + service            = "servicenetworking.googleapis.com"
    }

  # module.networking.google_service_networking_connection.cloudsql_psa_connection will be created
  + resource "google_service_networking_connection" "cloudsql_psa_connection" {
      + id                      = (known after apply)
      + network                 = (known after apply)
      + peering                 = (known after apply)
      + reserved_peering_ranges = [
          + "dev--cloudsql-psa-range",
        ]
      + service                 = "servicenetworking.googleapis.com"
    }

  # module.profiles.google_project_iam_member.cli_admin_logging_viewer will be created
  + resource "google_project_iam_member" "cli_admin_logging_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com"
      + project = "static-lead-454601-q1"
      + role    = "roles/logging.viewer"
    }

  # module.profiles.google_project_iam_member.cloud_function_compute_viewer will be created
  + resource "google_project_iam_member" "cloud_function_compute_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
      + project = "static-lead-454601-q1"
      + role    = "roles/compute.viewer"
    }

  # module.profiles.google_project_iam_member.cloud_function_logging_viewer will be created
  + resource "google_project_iam_member" "cloud_function_logging_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
      + project = "static-lead-454601-q1"
      + role    = "roles/logging.viewer"
    }

  # module.profiles.google_project_iam_member.cloud_function_monitoring_viewer will be created
  + resource "google_project_iam_member" "cloud_function_monitoring_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
      + project = "static-lead-454601-q1"
      + role    = "roles/monitoring.viewer"
    }

  # module.profiles.google_project_iam_member.compute_viewer will be created
  + resource "google_project_iam_member" "compute_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
      + project = "static-lead-454601-q1"
      + role    = "roles/compute.viewer"
    }

  # module.profiles.google_project_iam_member.logging_viewer will be created
  + resource "google_project_iam_member" "logging_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
      + project = "static-lead-454601-q1"
      + role    = "roles/logging.viewer"
    }

  # module.profiles.google_project_iam_member.monitoring_viewer will be created
  + resource "google_project_iam_member" "monitoring_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
      + project = "static-lead-454601-q1"
      + role    = "roles/monitoring.viewer"
    }

  # module.profiles.google_service_account.cloud_function will be created
  + resource "google_service_account" "cloud_function" {
      + account_id   = "dev--ro--cloud-function"
      + disabled     = false
      + display_name = "Cloud Function SA (Stress Test)"
      + email        = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
      + id           = (known after apply)
      + member       = "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
      + name         = (known after apply)
      + project      = "static-lead-454601-q1"
      + unique_id    = (known after apply)
    }

  # module.profiles.google_service_account.read_only will be created
  + resource "google_service_account" "read_only" {
      + account_id   = "dev--ro--service-account"
      + disabled     = false
      + display_name = "Read-Only Service Account for dev"
      + email        = "dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
      + id           = (known after apply)
      + member       = "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
      + name         = (known after apply)
      + project      = "static-lead-454601-q1"
      + unique_id    = (known after apply)
    }

Plan: 32 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cloud_function_bucket                     = "dev--cloud-function-bucket"
  + cloud_function_name                       = "dev--webapp-stress-tester"
  + cloud_function_region                     = "us-west2"
  + cloud_function_service_account_email      = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
  + cloud_function_service_account_unique_id  = (known after apply)
  + cloud_function_url                        = (known after apply)
  + cloudsql_psa_range_name                   = "dev--cloudsql-psa-range"
  + compute_instance_template                 = (known after apply)
  + compute_instance_type                     = "e2-micro"
  + compute_web_autoscaler_name               = "dev--web-autoscaling"
  + compute_web_server_ip                     = (known after apply)
  + compute_web_servers_group                 = (known after apply)
  + environment_config                        = {
      + policies = {
          + autoscaling = {
              + cooldown  = 60
              + max       = 3
              + min       = 1
              + threshold = 0.6
            }
          + stressload  = "low"
        }
      + region   = "west"
      + target   = "development"
      + type     = "micro"
    }
  + firewall_console_ips                      = [
      + "35.235.240.0/20",
    ]
  + firewall_devops_ips                       = [
      + "68.109.187.94",
    ]
  + firewall_private_ips                      = [
      + "10.0.0.0/8",
    ]
  + firewall_public_http_ranges               = [
      + "0.0.0.0/0",
    ]
  + gcp_project_config                        = {
      + credentials = ""
      + project     = "static-lead-454601-q1"
      + provider    = "gcp"
      + regions     = {
          + central = "us-central2"
          + east    = "us-east2"
          + west    = "us-west2"
        }
      + services    = {
          + cloud_function    = {
              + archive_name   = "stressload-webservers.zip"
              + archive_path   = "./packages"
              + bucket_name    = "cloud-function-bucket"
              + description    = "Stub Cloud Function for stress testing framework"
              + entry_point    = "main"
              + env            = {
                  + TARGET_URL = ""
                }
              + event_type     = "google.cloud.functions.v2.eventTypes.EVENT_TRIGGERED"
              + force_destroy  = true
              + invoker_member = "allUsers"
              + invoker_role   = "roles/cloudfunctions.invoker"
              + memory         = "256M"
              + name           = "webapp-stress-tester"
              + pubsub_topic   = null
              + runtime        = "python311"
              + timeout        = 60
            }
          + compute_resources = {
              + base_instance_name            = "web-server"
              + health_check                  = {
                  + interval = 5
                  + name     = "http-health-check"
                  + port     = 80
                  + timeout  = 5
                }
              + instance_group_name           = "web-servers-group"
              + instance_tags                 = [
                  + "ssh-access",
                  + "http-server",
                ]
              + instance_template_name_prefix = "web-server-template--"
              + source_image                  = "debian-cloud/debian-11"
              + startup_script_path           = "./scripts/configure/apache-webserver.shell"
            }
          + firewall_rules    = {
              + allow_http_https   = {
                  + name     = "allow-http-https"
                  + ports    = [
                      + "80",
                      + "443",
                    ]
                  + protocol = "tcp"
                }
              + allow_ssh          = {
                  + name        = "allow-ssh-restricted"
                  + ports       = [
                      + "22",
                    ]
                  + protocol    = "tcp"
                  + target_tags = [
                      + "ssh-access",
                    ]
                }
              + allow_ssh_iap      = {
                  + name        = "allow-ssh-iap"
                  + ports       = [
                      + "22",
                    ]
                  + protocol    = "tcp"
                  + target_tags = [
                      + "ssh-access",
                    ]
                }
              + public_http_ranges = [
                  + "0.0.0.0/0",
                ]
            }
          + health_check      = {
              + name = "http-health-check"
            }
          + http_forwarding   = {
              + name = "http-forwarding-rule"
            }
          + load_balancer     = {
              + health_check    = {
                  + interval = 5
                  + name     = "http-health-check"
                  + port     = 80
                  + timeout  = 5
                }
              + http_forwarding = {
                  + name       = "http-forwarding-rule"
                  + port_range = "80"
                  + scheme     = "EXTERNAL"
                }
              + http_proxy      = {
                  + name = "web-http-proxy"
                }
              + url_map         = {
                  + name = "web-url-map"
                }
              + web_backend     = {
                  + name     = "web-backend-service"
                  + protocol = "HTTP"
                  + timeout  = 30
                }
            }
          + networking        = {
              + management              = {
                  + enable                   = false
                  + private_ip_google_access = true
                  + subnet_cidr              = "10.90.0.0/24"
                  + subnet_name              = "mgmt-subnet"
                  + vpc_name                 = "mgmt-vpc"
                }
              + nat                     = {
                  + config_name        = "webapp-nat-config"
                  + enable_nat_logging = true
                  + nat_logging_filter = "ERRORS_ONLY"
                  + router_name        = "webapp-router"
                  + timeouts           = {
                      + icmp_idle_sec       = 30
                      + tcp_established_sec = 1200
                      + tcp_transitory_sec  = 30
                      + udp_idle_sec        = 30
                    }
                }
              + psa_range_name          = "cloudsql-psa-range"
              + psa_range_prefix_length = 16
              + subnet_cidr             = "10.100.0.0/24"
              + subnet_name             = "webapp-subnet"
              + vpc_network_name        = "webapp-vpc"
            }
          + web_autoscaling   = {
              + name = "web-autoscaling"
            }
          + web_backend       = {
              + name = "web-backend-service"
            }
        }
      + types       = {
          + medium   = "e2-medium"
          + micro    = "e2-micro"
          + standard = "n1-standard-1"
        }
    }
  + gcp_project_id                            = "static-lead-454601-q1"
  + http_forwarding_rule_name                 = "dev--http-forwarding-rule"
  + http_health_check_name                    = "dev--http-health-check"
  + load_balancer_ip                          = (known after apply)
  + nat_name                                  = "dev--webapp-nat-config"
  + readonly_service_account_email            = "dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
  + readonly_service_account_id               = (known after apply)
  + region                                    = "us-west2"
  + router_name                               = "dev--webapp-router"
  + stressload_config                         = {
      + duration = 90
      + interval = 0.1
      + requests = 1000
      + threads  = 10
    }
  + stressload_function_bucket                = "dev--cloud-function-bucket"
  + stressload_function_name                  = "dev--webapp-stress-tester"
  + stressload_function_region                = "us-west2"
  + stressload_function_service_account_email = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
  + stressload_key                            = "low"
  + stressload_log_level                      = "info"
  + subnet_id                                 = (known after apply)
  + vpc_network_id                            = (known after apply)
  + web_backend_service_name                  = "dev--web-backend-service"
  + workspace                                 = "dev"
```

```hcl
Do you want to perform these actions in workspace "dev"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

```hcl
module.networking.google_project_service.servicenetworking: Creating...
module.profiles.google_project_iam_member.cli_admin_logging_viewer: Creating...
module.profiles.google_service_account.cloud_function: Creating...
module.profiles.google_service_account.read_only: Creating...
module.networking.google_compute_network.vpc_network: Creating...
module.compute.google_compute_health_check.http: Creating...
module.load_balancer.google_compute_health_check.http: Creating...
module.cloud_function.google_storage_bucket.function_bucket: Creating...
module.cloud_function.google_storage_bucket.function_bucket: Creation complete after 1s [id=dev--cloud-function-bucket]
module.cloud_function.google_storage_bucket_object.function_archive: Creating...
module.cloud_function.google_storage_bucket_object.function_archive: Creation complete after 0s [id=dev--cloud-function-bucket-dev--stressload-webservers.zip]
module.profiles.google_project_iam_member.cli_admin_logging_viewer: Creation complete after 7s [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com]
module.networking.google_compute_network.vpc_network: Still creating... [10s elapsed]
module.networking.google_project_service.servicenetworking: Still creating... [10s elapsed]
module.profiles.google_service_account.read_only: Still creating... [10s elapsed]
module.profiles.google_service_account.cloud_function: Still creating... [10s elapsed]
module.compute.google_compute_health_check.http: Still creating... [10s elapsed]
module.load_balancer.google_compute_health_check.http: Still creating... [10s elapsed]
module.load_balancer.google_compute_health_check.http: Creation complete after 11s [id=projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check]
module.profiles.google_service_account.cloud_function: Creation complete after 11s [id=projects/static-lead-454601-q1/serviceAccounts/dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_logging_viewer: Creating...
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer: Creating...
module.profiles.google_project_iam_member.cloud_function_compute_viewer: Creating...
module.cloud_function.google_cloudfunctions2_function.cloud_function: Creating...
module.compute.google_compute_health_check.http: Creation complete after 11s [id=projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check-us-west2]
module.profiles.google_service_account.read_only: Creation complete after 13s [id=projects/static-lead-454601-q1/serviceAccounts/dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.logging_viewer: Creating...
module.profiles.google_project_iam_member.monitoring_viewer: Creating...
module.profiles.google_project_iam_member.compute_viewer: Creating...
module.profiles.google_project_iam_member.logging_viewer: Creation complete after 6s [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_compute_viewer: Creation complete after 8s [id=static-lead-454601-q1/roles/compute.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_logging_viewer: Creation complete after 8s [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.compute_viewer: Creation complete after 7s [id=static-lead-454601-q1/roles/compute.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.networking.google_compute_network.vpc_network: Still creating... [20s elapsed]
module.networking.google_project_service.servicenetworking: Still creating... [20s elapsed]
module.profiles.google_project_iam_member.monitoring_viewer: Creation complete after 7s [id=static-lead-454601-q1/roles/monitoring.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer: Creation complete after 9s [id=static-lead-454601-q1/roles/monitoring.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.networking.google_project_service.servicenetworking: Creation complete after 21s [id=static-lead-454601-q1/servicenetworking.googleapis.com]
module.cloud_function.google_cloudfunctions2_function.cloud_function: Still creating... [10s elapsed]
module.networking.google_compute_network.vpc_network: Creation complete after 22s [id=projects/static-lead-454601-q1/global/networks/dev--webapp-vpc]
module.networking.google_compute_global_address.cloudsql_psa_range: Creating...
module.networking.google_compute_router.nat_router: Creating...
module.networking.google_compute_subnetwork.subnet: Creating...
module.firewall.google_compute_firewall.allow_http_https: Creating...
module.firewall.google_compute_firewall.allow_ssh_iap: Creating...
module.firewall.google_compute_firewall.allow_ssh: Creating...
module.cloud_function.google_cloudfunctions2_function.cloud_function: Still creating... [20s elapsed]
module.networking.google_compute_router.nat_router: Still creating... [10s elapsed]
module.networking.google_compute_global_address.cloudsql_psa_range: Still creating... [10s elapsed]
module.networking.google_compute_subnetwork.subnet: Still creating... [10s elapsed]
module.firewall.google_compute_firewall.allow_http_https: Still creating... [10s elapsed]
module.firewall.google_compute_firewall.allow_ssh_iap: Still creating... [10s elapsed]
module.firewall.google_compute_firewall.allow_ssh: Still creating... [10s elapsed]
module.networking.google_compute_router.nat_router: Creation complete after 11s [id=projects/static-lead-454601-q1/regions/us-west2/routers/dev--webapp-router]
module.networking.google_compute_router_nat.nat_config: Creating...
module.firewall.google_compute_firewall.allow_ssh_iap: Creation complete after 11s [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-iap]
module.firewall.google_compute_firewall.allow_http_https: Creation complete after 11s [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-http-https]
module.firewall.google_compute_firewall.allow_ssh: Creation complete after 11s [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-restricted]
module.networking.google_compute_subnetwork.subnet: Creation complete after 12s [id=projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet]
module.compute.google_compute_instance_template.web_server: Creating...
module.networking.google_compute_global_address.cloudsql_psa_range: Creation complete after 12s [id=projects/static-lead-454601-q1/global/addresses/dev--cloudsql-psa-range]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Creating...
module.compute.google_compute_instance_template.web_server: Creation complete after 2s [id=projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250402010843051800000001]
module.compute.google_compute_region_instance_group_manager.web_servers: Creating...
module.cloud_function.google_cloudfunctions2_function.cloud_function: Still creating... [30s elapsed]
module.networking.google_compute_router_nat.nat_config: Still creating... [10s elapsed]
module.networking.google_compute_router_nat.nat_config: Creation complete after 11s [id=static-lead-454601-q1/us-west2/dev--webapp-router/dev--webapp-nat-config]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [10s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still creating... [10s elapsed]
module.cloud_function.google_cloudfunctions2_function.cloud_function: Still creating... [40s elapsed]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [20s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still creating... [20s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Creation complete after 21s [id=projects/static-lead-454601-q1/regions/us-west2/instanceGroupManagers/dev--web-servers-group]
module.compute.google_compute_region_autoscaler.web_autoscaler: Creating...
module.load_balancer.google_compute_backend_service.web_backend: Creating...
module.cloud_function.google_cloudfunctions2_function.cloud_function: Still creating... [50s elapsed]
module.cloud_function.google_cloudfunctions2_function.cloud_function: Creation complete after 52s [id=projects/static-lead-454601-q1/locations/us-west2/functions/dev--webapp-stress-tester]
module.cloud_function.google_cloudfunctions2_function_iam_member.invoker: Creating...
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [30s elapsed]
module.compute.google_compute_region_autoscaler.web_autoscaler: Still creating... [10s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still creating... [10s elapsed]
module.cloud_function.google_cloudfunctions2_function_iam_member.invoker: Creation complete after 4s [id=projects/static-lead-454601-q1/locations/us-west2/functions/dev--webapp-stress-tester/roles/cloudfunctions.invoker/allUsers]
module.compute.google_compute_region_autoscaler.web_autoscaler: Creation complete after 11s [id=projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [40s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still creating... [20s elapsed]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [50s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still creating... [30s elapsed]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [1m0s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still creating... [40s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Creation complete after 42s [id=projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service]
module.load_balancer.google_compute_url_map.default: Creating...
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [1m10s elapsed]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Creation complete after 1m12s [id=projects%2Fstatic-lead-454601-q1%2Fglobal%2Fnetworks%2Fdev--webapp-vpc:servicenetworking.googleapis.com]
module.load_balancer.google_compute_url_map.default: Still creating... [10s elapsed]
module.load_balancer.google_compute_url_map.default: Creation complete after 11s [id=projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map]
module.load_balancer.google_compute_target_http_proxy.default: Creating...
module.load_balancer.google_compute_target_http_proxy.default: Still creating... [10s elapsed]
module.load_balancer.google_compute_target_http_proxy.default: Creation complete after 11s [id=projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy]
module.load_balancer.google_compute_global_forwarding_rule.http: Creating...
module.load_balancer.google_compute_global_forwarding_rule.http: Still creating... [10s elapsed]
module.load_balancer.google_compute_global_forwarding_rule.http: Still creating... [20s elapsed]
module.load_balancer.google_compute_global_forwarding_rule.http: Creation complete after 22s [id=projects/static-lead-454601-q1/global/forwardingRules/dev--http-forwarding-rule]

Apply complete! Resources: 32 added, 0 changed, 0 destroyed.
```

```hcl
Outputs:

cloud_function_bucket = "dev--cloud-function-bucket"
cloud_function_name = "dev--webapp-stress-tester"
cloud_function_region = "us-west2"
cloud_function_service_account_email = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
cloud_function_service_account_unique_id = "113109902191687747883"
cloud_function_url = "https://dev--webapp-stress-tester-u66fpmlp3a-wl.a.run.app"
cloudsql_psa_range_name = "dev--cloudsql-psa-range"
compute_instance_template = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250402010843051800000001"
compute_instance_type = "e2-micro"
compute_web_autoscaler_name = "dev--web-autoscaling"
compute_web_server_ip = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group"
compute_web_servers_group = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group"
environment_config = {
  "policies" = {
    "autoscaling" = {
      "cooldown" = 60
      "max" = 3
      "min" = 1
      "threshold" = 0.6
    }
    "stressload" = "low"
  }
  "region" = "west"
  "target" = "development"
  "type" = "micro"
}
firewall_console_ips = tolist([
  "35.235.240.0/20",
])
firewall_devops_ips = tolist([
  "68.109.187.94",
])
firewall_private_ips = tolist([
  "10.0.0.0/8",
])
firewall_public_http_ranges = tolist([
  "0.0.0.0/0",
])
gcp_project_config = {
  "credentials" = ""
  "project" = "static-lead-454601-q1"
  "provider" = "gcp"
  "regions" = {
    "central" = "us-central2"
    "east" = "us-east2"
    "west" = "us-west2"
  }
  "services" = {
    "cloud_function" = {
      "archive_name" = "stressload-webservers.zip"
      "archive_path" = "./packages"
      "bucket_name" = "cloud-function-bucket"
      "description" = "Stub Cloud Function for stress testing framework"
      "entry_point" = "main"
      "env" = {
        "TARGET_URL" = ""
      }
      "event_type" = "google.cloud.functions.v2.eventTypes.EVENT_TRIGGERED"
      "force_destroy" = true
      "invoker_member" = "allUsers"
      "invoker_role" = "roles/cloudfunctions.invoker"
      "memory" = "256M"
      "name" = "webapp-stress-tester"
      "pubsub_topic" = null
      "runtime" = "python311"
      "timeout" = 60
    }
    "compute_resources" = {
      "base_instance_name" = "web-server"
      "health_check" = {
        "interval" = 5
        "name" = "http-health-check"
        "port" = 80
        "timeout" = 5
      }
      "instance_group_name" = "web-servers-group"
      "instance_tags" = [
        "ssh-access",
        "http-server",
      ]
      "instance_template_name_prefix" = "web-server-template--"
      "source_image" = "debian-cloud/debian-11"
      "startup_script_path" = "./scripts/configure/apache-webserver.shell"
    }
    "firewall_rules" = {
      "allow_http_https" = {
        "name" = "allow-http-https"
        "ports" = [
          "80",
          "443",
        ]
        "protocol" = "tcp"
      }
      "allow_ssh" = {
        "name" = "allow-ssh-restricted"
        "ports" = [
          "22",
        ]
        "protocol" = "tcp"
        "target_tags" = [
          "ssh-access",
        ]
      }
      "allow_ssh_iap" = {
        "name" = "allow-ssh-iap"
        "ports" = [
          "22",
        ]
        "protocol" = "tcp"
        "target_tags" = [
          "ssh-access",
        ]
      }
      "public_http_ranges" = [
        "0.0.0.0/0",
      ]
    }
    "health_check" = {
      "name" = "http-health-check"
    }
    "http_forwarding" = {
      "name" = "http-forwarding-rule"
    }
    "load_balancer" = {
      "health_check" = {
        "interval" = 5
        "name" = "http-health-check"
        "port" = 80
        "timeout" = 5
      }
      "http_forwarding" = {
        "name" = "http-forwarding-rule"
        "port_range" = "80"
        "scheme" = "EXTERNAL"
      }
      "http_proxy" = {
        "name" = "web-http-proxy"
      }
      "url_map" = {
        "name" = "web-url-map"
      }
      "web_backend" = {
        "name" = "web-backend-service"
        "protocol" = "HTTP"
        "timeout" = 30
      }
    }
    "networking" = {
      "management" = {
        "enable" = false
        "private_ip_google_access" = true
        "subnet_cidr" = "10.90.0.0/24"
        "subnet_name" = "mgmt-subnet"
        "vpc_name" = "mgmt-vpc"
      }
      "nat" = {
        "config_name" = "webapp-nat-config"
        "enable_nat_logging" = true
        "nat_logging_filter" = "ERRORS_ONLY"
        "router_name" = "webapp-router"
        "timeouts" = {
          "icmp_idle_sec" = 30
          "tcp_established_sec" = 1200
          "tcp_transitory_sec" = 30
          "udp_idle_sec" = 30
        }
      }
      "psa_range_name" = "cloudsql-psa-range"
      "psa_range_prefix_length" = 16
      "subnet_cidr" = "10.100.0.0/24"
      "subnet_name" = "webapp-subnet"
      "vpc_network_name" = "webapp-vpc"
    }
    "web_autoscaling" = {
      "name" = "web-autoscaling"
    }
    "web_backend" = {
      "name" = "web-backend-service"
    }
  }
  "types" = {
    "medium" = "e2-medium"
    "micro" = "e2-micro"
    "standard" = "n1-standard-1"
  }
}
gcp_project_id = "static-lead-454601-q1"
http_forwarding_rule_name = "dev--http-forwarding-rule"
http_health_check_name = "dev--http-health-check"
load_balancer_ip = "34.8.227.38"
nat_name = "dev--webapp-nat-config"
readonly_service_account_email = "dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
readonly_service_account_id = "116452779774764146207"
region = "us-west2"
router_name = "dev--webapp-router"
stressload_config = tomap({
  "duration" = 90
  "interval" = 0.1
  "requests" = 1000
  "threads" = 10
})
stressload_function_bucket = "dev--cloud-function-bucket"
stressload_function_name = "dev--webapp-stress-tester"
stressload_function_region = "us-west2"
stressload_function_service_account_email = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
stressload_key = "low"
stressload_log_level = "info"
subnet_id = "projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet"
vpc_network_id = "projects/static-lead-454601-q1/global/networks/dev--webapp-vpc"
web_backend_service_name = "dev--web-backend-service"
workspace = "dev"
```

```bash
$ ./scripts/manage/package-functions.shell ;
Terraform outputs extracted.

Extracting Cloud Function configurations (terraform state)...
Created Config-File:  scripts/stressload/webservers/config.json
```

```json
{
  "target_url": "http://34.8.227.38",
  "project_id": "static-lead-454601-q1",
  "region": "us-west2",
  "mig_name": "dev--web-servers-group",
  "autoscaler_name": "dev--web-autoscaling",
  "log_level": "info",
  "stress_duration_seconds": 90,
  "stress_concurrency": 10,
  "request_sleep_interval": 0.1,
  "autoscaler_min_replicas": 1,
  "autoscaler_max_replicas": 3
}
```

```bash
Including: scripts/stressload/webservers/main.py
Including: scripts/stressload/webservers/requirements.txt
Including: scripts/stressload/webservers/config.json

Packaging: [scripts/stressload/webservers] stressload-webservers.zip
  adding: main.py (deflated 65%)
  adding: requirements.txt (deflated 8%)
  adding: config.json (deflated 42%)

Created archive: packages/stressload-webservers.zip

Archive:  stressload-webservers.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
     4802  04-01-2025 14:39   main.py
       90  03-28-2025 07:08   requirements.txt
      372  04-01-2025 18:11   config.json
---------                     -------
     5264                     3 files
/Users/emvaldes/.repos/github/terraform/prototype/packages


Deploying Cloud Function...

Project ID: static-lead-454601-q1
Service Account:  dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com

Function Region:  us-west2
Function Name:    dev--webapp-stress-tester
Function Bucket:  dev--cloud-function-bucket

Archive Filename: stressload-webservers.zip
Archive Bucket:   dev--cloud-function-bucket/stressload-webservers.zip

Copying file://packages/stressload-webservers.zip [Content-Type=application/zip]...
/ [1 files][  2.4 KiB/  2.4 KiB]                                                
Operation completed over 1 objects/2.4 KiB.                                      
Preparing function...done.                                                                                                                                                                                                                                
X Updating function (may take a while)...                                                                                                                                                                                                                 
  ✓ [Build] Logs are available at [https://console.cloud.google.com/cloud-build/builds;region=us-west2/901953cd-8ec4-4382-b009-2f8afba13c01?project=776293755095]                                                                                         
    [Service]                                                                                                                                                                                                                                             
  . [ArtifactRegistry]                                                                                                                                                                                                                                    
  . [Healthcheck]                                                                                                                                                                                                                                         
  . [Triggercheck]                                                                                                                                                                                                                                        
Completed with warnings:                                                                                                                                                                                                                                  
  [INFO] A new revision will be deployed serving with 100% traffic.
You can view your function in the Cloud Console here: https://console.cloud.google.com/functions/details/us-west2/dev--webapp-stress-tester?project=static-lead-454601-q1

buildConfig:
  automaticUpdatePolicy: {}
  build: projects/776293755095/locations/us-west2/builds/901953cd-8ec4-4382-b009-2f8afba13c01
  dockerRegistry: ARTIFACT_REGISTRY
  dockerRepository: projects/static-lead-454601-q1/locations/us-west2/repositories/gcf-artifacts
  entryPoint: main
  runtime: python311
  serviceAccount: projects/static-lead-454601-q1/serviceAccounts/776293755095-compute@developer.gserviceaccount.com
  source:
    storageSource:
      bucket: gcf-v2-sources-776293755095-us-west2
      generation: '1743556273265178'
      object: dev--webapp-stress-tester/function-source.zip
  sourceProvenance:
    resolvedStorageSource:
      bucket: gcf-v2-sources-776293755095-us-west2
      generation: '1743556273265178'
      object: dev--webapp-stress-tester/function-source.zip
createTime: '2025-04-02T01:08:21.206431383Z'
description: Stub Cloud Function for stress testing framework
environment: GEN_2
labels:
  goog-terraform-provisioned: 'true'
name: projects/static-lead-454601-q1/locations/us-west2/functions/dev--webapp-stress-tester
satisfiesPzi: true
serviceConfig:
  allTrafficOnLatestRevision: true
  availableCpu: '0.1666'
  availableMemory: 256M
  environmentVariables:
    LOG_EXECUTION_ID: 'true'
    TARGET_URL: ''
  ingressSettings: ALLOW_ALL
  maxInstanceCount: 100
  maxInstanceRequestConcurrency: 1
  revision: dev--webapp-stress-tester-00002-lut
  service: projects/static-lead-454601-q1/locations/us-west2/services/dev--webapp-stress-tester
  serviceAccountEmail: dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com
  timeoutSeconds: 60
  uri: https://dev--webapp-stress-tester-u66fpmlp3a-wl.a.run.app
state: ACTIVE
updateTime: '2025-04-02T01:11:49.258283354Z'
url: https://us-west2-static-lead-454601-q1.cloudfunctions.net/dev--webapp-stress-tester

Done!
```

```bash
$ ./scripts/manage/inspect-services.shell $( terraform output -raw http_forwarding_rule_name ) ;

================================================================================
Forwarding Rule Description: dev--http-forwarding-rule
gcloud compute forwarding-rules describe dev--http-forwarding-rule --global --format=json
```

```json
{
  "IPAddress": "34.8.227.38",
  "IPProtocol": "TCP",
  "creationTimestamp": "2025-04-01T18:10:11.832-07:00",
  "description": "",
  "fingerprint": "uFJneYVugTU=",
  "id": "4461036371431207068",
  "kind": "compute#forwardingRule",
  "labelFingerprint": "42WmSpB8rSM=",
  "loadBalancingScheme": "EXTERNAL",
  "name": "dev--http-forwarding-rule",
  "networkTier": "PREMIUM",
  "portRange": "80-80",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/forwardingRules/dev--http-forwarding-rule",
  "target": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy"
}
```

```bash
External IP: 34.8.227.38
Target Proxy: dev--web-http-proxy

================================================================================
Target HTTP Proxy: dev--web-http-proxy
gcloud compute target-http-proxies describe dev--web-http-proxy --format=json
```

```json
{
  "creationTimestamp": "2025-04-01T18:10:00.195-07:00",
  "fingerprint": "v7iWTG4S3HE=",
  "id": "3744148738512334983",
  "kind": "compute#targetHttpProxy",
  "name": "dev--web-http-proxy",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy",
  "urlMap": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map"
}
```

```bash
URL Map: dev--web-url-map

================================================================================
URL Map: dev--web-url-map
gcloud compute url-maps describe dev--web-url-map --format=json
```

```json
{
  "creationTimestamp": "2025-04-01T18:09:48.902-07:00",
  "defaultService": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service",
  "fingerprint": "7wmjttrtkLg=",
  "id": "7947817695657930931",
  "kind": "compute#urlMap",
  "name": "dev--web-url-map",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map"
}
```

```bash
Backend Service: dev--web-backend-service

================================================================================
Backend Service: dev--web-backend-service
gcloud compute backend-services describe dev--web-backend-service --global --format=json
```

```json
{
  "affinityCookieTtlSec": 0,
  "backends": [
    {
      "balancingMode": "UTILIZATION",
      "capacityScaler": 1.0,
      "group": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group"
    }
  ],
  "connectionDraining": {
    "drainingTimeoutSec": 300
  },
  "creationTimestamp": "2025-04-01T18:09:06.769-07:00",
  "description": "",
  "enableCDN": false,
  "fingerprint": "NuvUAmmV5Yc=",
  "healthChecks": [
    "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check"
  ],
  "id": "5447375976029827293",
  "kind": "compute#backendService",
  "loadBalancingScheme": "EXTERNAL",
  "name": "dev--web-backend-service",
  "port": 80,
  "portName": "http",
  "protocol": "HTTP",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service",
  "sessionAffinity": "NONE",
  "timeoutSec": 30,
  "usedBy": [
    {
      "reference": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map"
    }
  ]
}
```

```bash
Group Instance:     dev--web-servers-group
Group Region:       us-west2
HTTP Health Check:  dev--http-health-check

================================================================================
Backend Health Status
gcloud compute backend-services get-health dev--web-backend-service --global --format=json
```

```json
[
  {
    "backend": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group",
    "status": {
      "healthStatus": [
        {
          "healthState": "HEALTHY",
          "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-b/instances/dev--web-server-hct4",
          "ipAddress": "10.100.0.2",
          "port": 80
        }
      ],
      "kind": "compute#backendServiceGroupHealth"
    }
  }
]
```

```bash
Health Status - State: HEALTHY

================================================================================
Health Check Configuration: dev--http-health-check
gcloud compute health-checks describe dev--http-health-check --format=json --project=static-lead-454601-q1
```

```json
{
  "checkIntervalSec": 5,
  "creationTimestamp": "2025-04-01T18:08:09.081-07:00",
  "healthyThreshold": 2,
  "httpHealthCheck": {
    "port": 80,
    "proxyHeader": "NONE",
    "requestPath": "/"
  },
  "id": "2887258202674639638",
  "kind": "compute#healthCheck",
  "name": "dev--http-health-check",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check",
  "timeoutSec": 5,
  "type": "HTTP",
  "unhealthyThreshold": 2
}
```

```bash
Check Interval: 5 seconds
Timeout:        5 seconds
Port:           null

================================================================================
Web Server HTTP Response Check
curl --head --connect-timeout 10 http://34.8.227.38

Waiting for web-server (34.8.227.38) response 
HTTP/1.1 200 OK
Date: Wed, 02 Apr 2025 01:15:07 GMT
Server: Apache/2.4.62 (Debian)
Last-Modified: Wed, 02 Apr 2025 01:09:51 GMT
ETag: "3b-631c14f7804e1"
Accept-Ranges: bytes
Content-Length: 59
Content-Type: text/html
Via: 1.1 google

================================================================================
Autoscaler Configuration: dev--web-autoscaling
curl -H "Authorization: Bearer ***" https://compute.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling
```

```json
{
  "kind": "compute#autoscaler",
  "id": "3057099209766416605",
  "creationTimestamp": "2025-04-01T18:09:06.249-07:00",
  "name": "dev--web-autoscaling",
  "target": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroupManagers/dev--web-servers-group",
  "autoscalingPolicy": {
    "minNumReplicas": 1,
    "maxNumReplicas": 3,
    "coolDownPeriodSec": 60,
    "cpuUtilization": {
      "utilizationTarget": 0.6,
      "predictiveMethod": "NONE"
    },
    "mode": "ON"
  },
  "region": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling",
  "status": "ACTIVE",
  "recommendedSize": 1
}
```

```bash
Min Replicas: 1
Max Replicas: 3
Cooldown:     60
CPU Target:   0.6

================================================================================
Reserved PSA IP Range: dev--cloudsql-psa-range
gcloud compute addresses describe dev--cloudsql-psa-range --global --project=static-lead-454601-q1 --format=json
```

```json
{
  "address": "10.126.0.0",
  "addressType": "INTERNAL",
  "creationTimestamp": "2025-04-01T18:08:31.465-07:00",
  "description": "",
  "id": "3242652852199436512",
  "kind": "compute#address",
  "labelFingerprint": "vezUS-42LLM=",
  "labels": {
    "goog-terraform-provisioned": "true"
  },
  "name": "dev--cloudsql-psa-range",
  "network": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc",
  "networkTier": "PREMIUM",
  "prefixLength": 16,
  "purpose": "VPC_PEERING",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/addresses/dev--cloudsql-psa-range",
  "status": "RESERVED"
}
```

```bash
Address Type: INTERNAL
Prefix Length: 16
Purpose: VPC_PEERING
Network: https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc

================================================================================
PSA VPC Peering Connections
gcloud services vpc-peerings list --network=dev--webapp-vpc --project=static-lead-454601-q1 --format=json
```

```json
[
  {
    "network": "projects/776293755095/global/networks/dev--webapp-vpc",
    "peering": "servicenetworking-googleapis-com",
    "reservedPeeringRanges": [
      "dev--cloudsql-psa-range"
    ],
    "service": "services/servicenetworking.googleapis.com"
  }
]
```

```bash
Completed the Application Load Balancer inspection.

Instance: dev--web-server-hct4 (us-west2-b)
```

```json
{
  "cpuPlatform": "Intel Broadwell",
  "creationTimestamp": "2025-04-01T18:09:02.570-07:00",
  "deletionProtection": false,
  "disks": [
    {
      "architecture": "X86_64",
      "autoDelete": true,
      "boot": true,
      "deviceName": "persistent-disk-0",
      "diskSizeGb": "10",
      "guestOsFeatures": [
        {
          "type": "UEFI_COMPATIBLE"
        },
        {
          "type": "VIRTIO_SCSI_MULTIQUEUE"
        },
        {
          "type": "GVNIC"
        }
      ],
      "index": 0,
      "interface": "SCSI",
      "kind": "compute#attachedDisk",
      "licenses": [
        "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/licenses/debian-11-bullseye"
      ],
      "mode": "READ_WRITE",
      "source": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-b/disks/dev--web-server-hct4",
      "type": "PERSISTENT"
    }
  ],
  "fingerprint": "0qaQc1Cu254=",
  "id": "2940854060179337409",
  "kind": "compute#instance",
  "labelFingerprint": "vezUS-42LLM=",
  "labels": {
    "goog-terraform-provisioned": "true"
  },
  "lastStartTimestamp": "2025-04-01T18:09:15.067-07:00",
  "machineType": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-b/machineTypes/e2-micro",
  "metadata": {
    "fingerprint": "eFrfaEJOHvo=",
    "items": [
      {
        "key": "instance-template",
        "value": "projects/776293755095/global/instanceTemplates/dev--web-server-template--20250402010843051800000001"
      },
      {
        "key": "created-by",
        "value": "projects/776293755095/regions/us-west2/instanceGroupManagers/dev--web-servers-group"
      },
      {
        "key": "startup-script",
        "value": "#!/bin/bash\n\n# File: ./scripts/configure/apache-webserver.shell\n# Version: 0.1.0\n\n# Update package lists\nsudo apt update -y;\n\n# Install Apache web server\nsudo apt install -y apache2;\n\n# Start and enable Apache\nsudo systemctl start apache2;\nsudo systemctl enable apache2;\n\n# Create a simple HTML page to verify the instance is running\necho -e \"<h1>Server $(hostname) is running behind ALB</h1>\" \\\n   | sudo tee /var/www/html/index.html;\n"
      }
    ],
    "kind": "compute#metadata"
  },
  "name": "dev--web-server-hct4",
  "networkInterfaces": [
    {
      "fingerprint": "3LOdllLHcMo=",
      "kind": "compute#networkInterface",
      "name": "nic0",
      "network": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc",
      "networkIP": "10.100.0.2",
      "stackType": "IPV4_ONLY",
      "subnetwork": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet"
    }
  ],
  "satisfiesPzi": true,
  "scheduling": {
    "automaticRestart": true,
    "onHostMaintenance": "MIGRATE",
    "preemptible": false,
    "provisioningModel": "STANDARD"
  },
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-b/instances/dev--web-server-hct4",
  "shieldedInstanceConfig": {
    "enableIntegrityMonitoring": true,
    "enableSecureBoot": false,
    "enableVtpm": true
  },
  "shieldedInstanceIntegrityPolicy": {
    "updateAutoLearnPolicy": true
  },
  "startRestricted": false,
  "status": "RUNNING",
  "tags": {
    "fingerprint": "COcCRvdHQf8=",
    "items": [
      "http-server",
      "ssh-access"
    ]
  },
  "zone": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-b"
}
```

```bash
================================================================================
Unified IAM Role & Profile Inspection for Terraform-Managed Identities

Terraform-Managed IAM Identities with Roles and Profiles:
```

```json
[
  {
    "member": "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com",
    "profile": {
      "name": "projects/static-lead-454601-q1/serviceAccounts/dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com",
      "email": "dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com",
      "displayName": "Read-Only Service Account for dev",
      "disabled": false,
      "description": null
    },
    "roles": [
      "roles/compute.viewer",
      "roles/logging.viewer",
      "roles/monitoring.viewer"
    ]
  },
  {
    "member": "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com",
    "profile": {
      "name": "projects/static-lead-454601-q1/serviceAccounts/dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com",
      "email": "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com",
      "displayName": "Cloud Function SA (Stress Test)",
      "disabled": false,
      "description": null
    },
    "roles": [
      "roles/compute.viewer",
      "roles/logging.viewer",
      "roles/monitoring.viewer"
    ]
  }
]
```

```bash
Exported:
  iam_terraform_identities_json (JSON)
  iam_scoped_member="dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
  iam_scoped_roles_json (JSON)
  iam_profile_json (JSON)

================================================================================
IAM Custom Roles Inspection (Full)

No custom IAM roles found in project: static-lead-454601-q1

================================================================================
IAM Policy Bindings Inspection (Scoped to Terraform-Managed Roles)

📌 Analyzing bindings for roles managed by Terraform...
```

```json
[
  {
    "role": "roles/compute.viewer",
    "managed": [
      "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com",
      "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
    ]
  },
  {
    "role": "roles/logging.viewer",
    "managed": [
      "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com",
      "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com",
      "serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com"
    ]
  },
  {
    "role": "roles/monitoring.viewer",
    "managed": [
      "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com",
      "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
    ]
  }
]
```

```bash
================================================================================
IAM Activity Logs (Terraform-Managed Identities)

Querying GCP logs for the following IAM members:
dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com
dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com

================================================================================
Autoscaler Activity Log Inspection

⚠️  No autoscaler logs found matching: autoscalers/

================================================================================
IAM Role Assignments Diff (Terraform vs. GCP)
```

```json
[
  {
    "member": "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com",
    "tf_roles": [
      "roles/compute.viewer",
      "roles/logging.viewer",
      "roles/monitoring.viewer"
    ],
    "gcp_roles": [
      "roles/compute.viewer",
      "roles/logging.viewer",
      "roles/monitoring.viewer"
    ],
    "missing_in_gcp": [],
    "extra_in_gcp": []
  },
  {
    "member": "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com",
    "tf_roles": [
      "roles/compute.viewer",
      "roles/logging.viewer",
      "roles/monitoring.viewer"
    ],
    "gcp_roles": [
      "roles/compute.viewer",
      "roles/logging.viewer",
      "roles/monitoring.viewer"
    ],
    "missing_in_gcp": [],
    "extra_in_gcp": []
  }
]
```

```bash
================================================================================
IAM Unbound Identities (Terraform-Managed Without GCP Role Bindings)

[]

================================================================================
IAM Key Origin Inspection (Terraform-Managed Service Accounts)

All Keys (User & System Managed):
```

```json
[
  {
    "service_account": "dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com",
    "name": "projects/static-lead-454601-q1/serviceAccounts/dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com/keys/1627cb49c5b329be92850cf7fe962c11731b9708",
    "key_type": "SYSTEM_MANAGED",
    "valid_after": "2025-04-02T01:08:09Z",
    "valid_before": "2027-04-17T11:08:39Z",
    "disabled": null
  },
  {
    "service_account": "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com",
    "name": "projects/static-lead-454601-q1/serviceAccounts/dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com/keys/7f65b4d92c23506359ea8b1738c2cd5012caa01e",
    "key_type": "SYSTEM_MANAGED",
    "valid_after": "2025-04-02T01:08:09Z",
    "valid_before": "2027-04-18T17:47:35Z",
    "disabled": null
  }
]
```

```bash
User-Managed Keys Detected (Active Only):
[]

================================================================================
IAM Key Expiration Inspection (Terraform-Managed Service Accounts)

No expired or expiring keys found (within 30 days).
```

```bash
$ hey -z 5m -c 100 http://$( terraform output -raw load_balancer_ip ) ;

Summary:
  Total:	300.0250 secs
  Slowest:	0.6839 secs
  Fastest:	0.0160 secs
  Average:	0.0480 secs
  Requests/sec:	2081.5567
  
  Total data:	36893304 bytes
  Size/request:	59 bytes

Response time histogram:
  0.016 [1]	|
  0.083 [538843]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.150 [16939]	|■
  0.216 [59908]	|■■■■
  0.283 [8817]	|■
  0.350 [3]	|
  0.417 [3]	|
  0.484 [2]	|
  0.550 [2]	|
  0.617 [0]	|
  0.684 [1]	|


Latency distribution:
  10% in 0.0237 secs
  25% in 0.0261 secs
  50% in 0.0280 secs
  75% in 0.0302 secs
  90% in 0.1633 secs
  95% in 0.1931 secs
  99% in 0.2190 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0000 secs, 0.0160 secs, 0.6839 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0006 secs
  resp wait:	0.0480 secs, 0.0160 secs, 0.6838 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0020 secs

Status code distribution:
  [200]	624348 responses
  [502]	171 responses
```

```bash
$ gcloud compute instance-groups \
         managed list-instances dev--web-servers-group \
         --region=us-west2 \
         --project=static-lead-454601-q1 \
         --format="json" ;
```

```json
$ gcloud compute instance-groups managed list-instances dev--web-servers-group   --region=us-west2   --project=static-lead-454601-q1   --format="json" ;
[
  {
    "currentAction": "NONE",
    "id": "4802981738890469181",
    "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-a/instances/dev--web-server-4l2g",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-4l2g",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250402010843051800000001"
    }
  },
  {
    "currentAction": "NONE",
    "id": "2940854060179337409",
    "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-b/instances/dev--web-server-hct4",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-hct4",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250402010843051800000001"
    }
  },
```

```json
  {
    "currentAction": "DELETING",
    "id": "5298641116835422013",
    "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-c/instances/dev--web-server-r8xz",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-r8xz"
  }
]
```

---

_This README describes the purpose and contents of `scripts/` as of April 1, 2025._

