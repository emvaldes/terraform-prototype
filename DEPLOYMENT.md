```bash
$ terraform init ;

Initializing the backend...

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing modules...
- cloud_function in modules/gcp/cloud_function
- compute in modules/gcp/compute
- firewall in modules/gcp/firewall
- load_balancer in modules/gcp/load_balancer
- networking in modules/gcp/networking
- profiles in modules/gcp/profiles
Initializing provider plugins...
- Finding latest version of hashicorp/google...
- Installing hashicorp/google v6.28.0...
- Installed hashicorp/google v6.28.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```console
$ create-workspaces ;

Workspace 'dev' already exists.
Workspace 'prod' already exists.
Workspace 'staging' already exists.
Switched to workspace "dev".

Terraform Workspace: dev
```

```console
$ terraform validate ;

Success! The configuration is valid.
```

```hcl
$ terraform apply ;

module.compute.data.google_compute_zones.available: Reading...
module.compute.data.google_compute_zones.available: Read complete after 0s [id=projects/static-lead-454601-q1/regions/us-west2]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated
with the following symbols:
  + create

Terraform will perform the following actions:

  # module.cloud_function[0].google_storage_bucket.function_bucket will be created
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

  # module.cloud_function[0].google_storage_bucket_object.function_archive[0] will be created
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
          + source_image           = "ubuntu-os-cloud/ubuntu-2004-lts"
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
          + max_replicas    = 2
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

  # module.profiles.google_project_iam_member.cli_admin_storage_admin will be created
  + resource "google_project_iam_member" "cli_admin_storage_admin" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com"
      + project = "static-lead-454601-q1"
      + role    = "roles/storage.admin"
    }

  # module.profiles.google_project_iam_member.cloud_function_compute_viewer[0] will be created
  + resource "google_project_iam_member" "cloud_function_compute_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
      + project = "static-lead-454601-q1"
      + role    = "roles/compute.viewer"
    }

  # module.profiles.google_project_iam_member.cloud_function_logging_viewer[0] will be created
  + resource "google_project_iam_member" "cloud_function_logging_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
      + project = "static-lead-454601-q1"
      + role    = "roles/logging.viewer"
    }

  # module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0] will be created
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

  # module.profiles.google_service_account.cloud_function[0] will be created
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

Plan: 31 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cloud_function_bucket                     = "dev--cloud-function-bucket"
  + cloud_function_service_account_email      = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
  + cloud_function_service_account_unique_id  = (known after apply)
  + cloud_function_upload_target              = "module.cloud_function[0].google_storage_bucket_object.function_archive"
  + cloudsql_psa_range_name                   = "dev--cloudsql-psa-range"
  + compute_instance_template                 = (known after apply)
  + compute_instance_type                     = "e2-micro"
  + compute_web_autoscaler_name               = "dev--web-autoscaling"
  + compute_web_server_ip                     = (known after apply)
  + compute_web_servers_group                 = (known after apply)
  + environment_config                        = {
      + description = "Development environment"
      + id          = "dev"
      + name        = "development"
      + policies    = {
          + autoscaling = "basic"
          + stressload  = "low"
        }
      + region      = "west"
      + type        = "micro"
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
      + project_id  = "static-lead-454601-q1"
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
              + auto_deploy    = false
              + bucket_name    = "cloud-function-bucket"
              + description    = "Stub Cloud Function for stress testing framework"
              + enable         = true
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
              + source_image                  = "ubuntu-os-cloud/ubuntu-2004-lts"
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
  + http_forwarding_rule_name                 = "dev--http-forwarding-rule"
  + http_health_check_name                    = "dev--http-health-check"
  + load_balancer_ip                          = (known after apply)
  + nat_name                                  = "dev--webapp-nat-config"
  + project_id                                = "static-lead-454601-q1"
  + readonly_service_account_email            = "dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
  + readonly_service_account_id               = (known after apply)
  + region                                    = "us-west2"
  + router_name                               = "dev--webapp-router"
  + stressload_config                         = {
      + duration = 60
      + interval = 0.04
      + requests = 10000
      + threads  = 250
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

Do you want to perform these actions in workspace "dev"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
```

```console
  Enter a value: yes
```

```hcl
module.profiles.google_project_iam_member.cli_admin_logging_viewer: Creating...
module.profiles.google_project_iam_member.cli_admin_storage_admin: Creating...
module.profiles.google_service_account.cloud_function[0]: Creating...
module.networking.google_project_service.servicenetworking: Creating...
module.networking.google_compute_network.vpc_network: Creating...
module.profiles.google_service_account.read_only: Creating...
module.compute.google_compute_health_check.http: Creating...
module.load_balancer.google_compute_health_check.http: Creating...
module.cloud_function[0].google_storage_bucket.function_bucket: Creating...
module.cloud_function[0].google_storage_bucket.function_bucket: Creation complete after 1s [id=dev--cloud-function-bucket]
module.cloud_function[0].google_storage_bucket_object.function_archive[0]: Creating...
module.cloud_function[0].google_storage_bucket_object.function_archive[0]: Creation complete after 1s [id=dev--cloud-function-bucket-dev--stressload-webservers.zip]
module.profiles.google_project_iam_member.cli_admin_logging_viewer: Creation complete after 8s [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cli_admin_storage_admin: Creation complete after 8s [id=static-lead-454601-q1/roles/storage.admin/serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_service_account.cloud_function[0]: Still creating... [10s elapsed]
module.networking.google_project_service.servicenetworking: Still creating... [10s elapsed]
module.profiles.google_service_account.read_only: Still creating... [10s elapsed]
module.networking.google_compute_network.vpc_network: Still creating... [10s elapsed]
module.compute.google_compute_health_check.http: Still creating... [10s elapsed]
module.load_balancer.google_compute_health_check.http: Still creating... [10s elapsed]
module.compute.google_compute_health_check.http: Creation complete after 11s [id=projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check-us-west2]
module.load_balancer.google_compute_health_check.http: Creation complete after 11s [id=projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check]
module.profiles.google_service_account.cloud_function[0]: Creation complete after 13s [id=projects/static-lead-454601-q1/serviceAccounts/dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_logging_viewer[0]: Creating...
module.profiles.google_project_iam_member.cloud_function_compute_viewer[0]: Creating...
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0]: Creating...
module.profiles.google_service_account.read_only: Creation complete after 13s [id=projects/static-lead-454601-q1/serviceAccounts/dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.logging_viewer: Creating...
module.profiles.google_project_iam_member.monitoring_viewer: Creating...
module.profiles.google_project_iam_member.compute_viewer: Creating...
module.networking.google_project_service.servicenetworking: Still creating... [20s elapsed]
module.networking.google_compute_network.vpc_network: Still creating... [20s elapsed]
module.profiles.google_project_iam_member.compute_viewer: Creation complete after 7s [id=static-lead-454601-q1/roles/compute.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_compute_viewer[0]: Creation complete after 8s [id=static-lead-454601-q1/roles/compute.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.monitoring_viewer: Creation complete after 8s [id=static-lead-454601-q1/roles/monitoring.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0]: Creation complete after 8s [id=static-lead-454601-q1/roles/monitoring.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_logging_viewer[0]: Creation complete after 8s [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.networking.google_project_service.servicenetworking: Creation complete after 21s [id=static-lead-454601-q1/servicenetworking.googleapis.com]
module.profiles.google_project_iam_member.logging_viewer: Creation complete after 8s [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.networking.google_compute_network.vpc_network: Creation complete after 22s [id=projects/static-lead-454601-q1/global/networks/dev--webapp-vpc]
module.networking.google_compute_global_address.cloudsql_psa_range: Creating...
module.networking.google_compute_router.nat_router: Creating...
module.networking.google_compute_subnetwork.subnet: Creating...
module.firewall.google_compute_firewall.allow_ssh_iap: Creating...
module.firewall.google_compute_firewall.allow_http_https: Creating...
module.firewall.google_compute_firewall.allow_ssh: Creating...
module.networking.google_compute_router.nat_router: Still creating... [10s elapsed]
module.networking.google_compute_global_address.cloudsql_psa_range: Still creating... [10s elapsed]
module.networking.google_compute_subnetwork.subnet: Still creating... [10s elapsed]
module.firewall.google_compute_firewall.allow_ssh_iap: Still creating... [10s elapsed]
module.firewall.google_compute_firewall.allow_http_https: Still creating... [10s elapsed]
module.firewall.google_compute_firewall.allow_ssh: Still creating... [10s elapsed]
module.networking.google_compute_router.nat_router: Creation complete after 11s [id=projects/static-lead-454601-q1/regions/us-west2/routers/dev--webapp-router]
module.networking.google_compute_router_nat.nat_config: Creating...
module.firewall.google_compute_firewall.allow_ssh_iap: Creation complete after 11s [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-iap]
module.firewall.google_compute_firewall.allow_ssh: Creation complete after 11s [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-restricted]
module.firewall.google_compute_firewall.allow_http_https: Creation complete after 11s [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-http-https]
module.networking.google_compute_global_address.cloudsql_psa_range: Creation complete after 11s [id=projects/static-lead-454601-q1/global/addresses/dev--cloudsql-psa-range]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Creating...
module.networking.google_compute_subnetwork.subnet: Still creating... [20s elapsed]
module.networking.google_compute_router_nat.nat_config: Still creating... [10s elapsed]
module.networking.google_compute_subnetwork.subnet: Creation complete after 21s [id=projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [10s elapsed]
module.networking.google_compute_router_nat.nat_config: Creation complete after 11s [id=static-lead-454601-q1/us-west2/dev--webapp-router/dev--webapp-nat-config]
module.compute.google_compute_instance_template.web_server: Creating...
module.compute.google_compute_instance_template.web_server: Creation complete after 2s [id=projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001]
module.compute.google_compute_region_instance_group_manager.web_servers: Creating...
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [20s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still creating... [10s elapsed]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [30s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still creating... [20s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Creation complete after 22s [id=projects/static-lead-454601-q1/regions/us-west2/instanceGroupManagers/dev--web-servers-group]
module.compute.google_compute_region_autoscaler.web_autoscaler: Creating...
module.load_balancer.google_compute_backend_service.web_backend: Creating...
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [40s elapsed]
module.compute.google_compute_region_autoscaler.web_autoscaler: Still creating... [10s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still creating... [10s elapsed]
module.compute.google_compute_region_autoscaler.web_autoscaler: Creation complete after 11s [id=projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still creating... [50s elapsed]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Creation complete after 52s [id=projects%2Fstatic-lead-454601-q1%2Fglobal%2Fnetworks%2Fdev--webapp-vpc:servicenetworking.googleapis.com]
module.load_balancer.google_compute_backend_service.web_backend: Still creating... [20s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still creating... [30s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still creating... [40s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Creation complete after 43s [id=projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service]
module.load_balancer.google_compute_url_map.default: Creating...
module.load_balancer.google_compute_url_map.default: Still creating... [10s elapsed]
module.load_balancer.google_compute_url_map.default: Creation complete after 12s [id=projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map]
module.load_balancer.google_compute_target_http_proxy.default: Creating...
module.load_balancer.google_compute_target_http_proxy.default: Still creating... [10s elapsed]
module.load_balancer.google_compute_target_http_proxy.default: Creation complete after 11s [id=projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy]
module.load_balancer.google_compute_global_forwarding_rule.http: Creating...
module.load_balancer.google_compute_global_forwarding_rule.http: Still creating... [10s elapsed]
module.load_balancer.google_compute_global_forwarding_rule.http: Still creating... [20s elapsed]
module.load_balancer.google_compute_global_forwarding_rule.http: Creation complete after 22s [id=projects/static-lead-454601-q1/global/forwardingRules/dev--http-forwarding-rule]

Apply complete! Resources: 31 added, 0 changed, 0 destroyed.
```

```console
Outputs:

cloud_function_bucket = "dev--cloud-function-bucket"
cloud_function_service_account_email = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
cloud_function_service_account_unique_id = "106698488519359597344"
cloud_function_upload_target = "module.cloud_function[0].google_storage_bucket_object.function_archive"
cloudsql_psa_range_name = "dev--cloudsql-psa-range"
compute_instance_template = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
compute_instance_type = "e2-micro"
compute_web_autoscaler_name = "dev--web-autoscaling"
compute_web_server_ip = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group"
compute_web_servers_group = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group"
```

```json
environment_config = {
  "description" = "Development environment"
  "id" = "dev"
  "name" = "development"
  "policies" = {
    "autoscaling" = "basic"
    "stressload" = "low"
  }
  "region" = "west"
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
  "project_id" = "static-lead-454601-q1"
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
      "auto_deploy" = false
      "bucket_name" = "cloud-function-bucket"
      "description" = "Stub Cloud Function for stress testing framework"
      "enable" = true
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
      "source_image" = "ubuntu-os-cloud/ubuntu-2004-lts"
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
```

```hcl
http_forwarding_rule_name = "dev--http-forwarding-rule"
http_health_check_name = "dev--http-health-check"
load_balancer_ip = "34.8.19.233"
nat_name = "dev--webapp-nat-config"
project_id = "static-lead-454601-q1"
readonly_service_account_email = "dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com"
readonly_service_account_id = "106725142199856657740"
region = "us-west2"
router_name = "dev--webapp-router"
stressload_config = tomap({
  "duration" = 60
  "interval" = 0.04
  "requests" = 10000
  "threads" = 250
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

```console
$ terraform destroy ;

module.compute.data.google_compute_zones.available: Reading...
module.profiles.google_project_iam_member.cli_admin_logging_viewer: Refreshing state... [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com]
module.networking.google_project_service.servicenetworking: Refreshing state... [id=static-lead-454601-q1/servicenetworking.googleapis.com]
module.profiles.google_project_iam_member.cli_admin_storage_admin: Refreshing state... [id=static-lead-454601-q1/roles/storage.admin/serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_service_account.cloud_function[0]: Refreshing state... [id=projects/static-lead-454601-q1/serviceAccounts/dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_service_account.read_only: Refreshing state... [id=projects/static-lead-454601-q1/serviceAccounts/dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.networking.google_compute_network.vpc_network: Refreshing state... [id=projects/static-lead-454601-q1/global/networks/dev--webapp-vpc]
module.load_balancer.google_compute_health_check.http: Refreshing state... [id=projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check]
module.compute.google_compute_health_check.http: Refreshing state... [id=projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check-us-west2]
module.cloud_function[0].google_storage_bucket.function_bucket: Refreshing state... [id=dev--cloud-function-bucket]
module.cloud_function[0].google_storage_bucket_object.function_archive[0]: Refreshing state... [id=dev--cloud-function-bucket-dev--stressload-webservers.zip]
module.compute.data.google_compute_zones.available: Read complete after 0s [id=projects/static-lead-454601-q1/regions/us-west2]
module.networking.google_compute_router.nat_router: Refreshing state... [id=projects/static-lead-454601-q1/regions/us-west2/routers/dev--webapp-router]
module.networking.google_compute_global_address.cloudsql_psa_range: Refreshing state... [id=projects/static-lead-454601-q1/global/addresses/dev--cloudsql-psa-range]
module.networking.google_compute_subnetwork.subnet: Refreshing state... [id=projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet]
module.firewall.google_compute_firewall.allow_http_https: Refreshing state... [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-http-https]
module.firewall.google_compute_firewall.allow_ssh_iap: Refreshing state... [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-iap]
module.firewall.google_compute_firewall.allow_ssh: Refreshing state... [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-restricted]
module.profiles.google_project_iam_member.cloud_function_compute_viewer[0]: Refreshing state... [id=static-lead-454601-q1/roles/compute.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0]: Refreshing state... [id=static-lead-454601-q1/roles/monitoring.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_logging_viewer[0]: Refreshing state... [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.logging_viewer: Refreshing state... [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.compute_viewer: Refreshing state... [id=static-lead-454601-q1/roles/compute.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.monitoring_viewer: Refreshing state... [id=static-lead-454601-q1/roles/monitoring.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.networking.google_compute_router_nat.nat_config: Refreshing state... [id=static-lead-454601-q1/us-west2/dev--webapp-router/dev--webapp-nat-config]
module.compute.google_compute_instance_template.web_server: Refreshing state... [id=projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001]
module.compute.google_compute_region_instance_group_manager.web_servers: Refreshing state... [id=projects/static-lead-454601-q1/regions/us-west2/instanceGroupManagers/dev--web-servers-group]
module.compute.google_compute_region_autoscaler.web_autoscaler: Refreshing state... [id=projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling]
module.load_balancer.google_compute_backend_service.web_backend: Refreshing state... [id=projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service]
module.load_balancer.google_compute_url_map.default: Refreshing state... [id=projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map]
module.load_balancer.google_compute_target_http_proxy.default: Refreshing state... [id=projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy]
module.load_balancer.google_compute_global_forwarding_rule.http: Refreshing state... [id=projects/static-lead-454601-q1/global/forwardingRules/dev--http-forwarding-rule]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Refreshing state... [id=projects%2Fstatic-lead-454601-q1%2Fglobal%2Fnetworks%2Fdev--webapp-vpc:servicenetworking.googleapis.com]
```

```hcl
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # module.cloud_function[0].google_storage_bucket.function_bucket will be destroyed
  - resource "google_storage_bucket" "function_bucket" {
      - default_event_based_hold    = false -> null
      - effective_labels            = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - enable_object_retention     = false -> null
      - force_destroy               = true -> null
      - id                          = "dev--cloud-function-bucket" -> null
      - labels                      = {} -> null
      - location                    = "US-WEST2" -> null
      - name                        = "dev--cloud-function-bucket" -> null
      - project                     = "static-lead-454601-q1" -> null
      - project_number              = 776293755095 -> null
      - public_access_prevention    = "inherited" -> null
      - requester_pays              = false -> null
      - self_link                   = "https://www.googleapis.com/storage/v1/b/dev--cloud-function-bucket" -> null
      - storage_class               = "STANDARD" -> null
      - terraform_labels            = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - uniform_bucket_level_access = false -> null
      - url                         = "gs://dev--cloud-function-bucket" -> null

      - hierarchical_namespace {
          - enabled = false -> null
        }

      - soft_delete_policy {
          - effective_time             = "2025-04-05T07:47:15.675Z" -> null
          - retention_duration_seconds = 604800 -> null
        }
    }

  # module.cloud_function[0].google_storage_bucket_object.function_archive[0] will be destroyed
  - resource "google_storage_bucket_object" "function_archive" {
      - bucket              = "dev--cloud-function-bucket" -> null
      - content_type        = "application/zip" -> null
      - crc32c              = "6rG9vg==" -> null
      - detect_md5hash      = "sDNq4gA/x5mdH5T5e/wDAw==" -> null
      - event_based_hold    = false -> null
      - generation          = 1743842376844696 -> null
      - id                  = "dev--cloud-function-bucket-dev--stressload-webservers.zip" -> null
      - md5hash             = "sDNq4gA/x5mdH5T5e/wDAw==" -> null
      - media_link          = "https://storage.googleapis.com/download/storage/v1/b/dev--cloud-function-bucket/o/dev--stressload-webservers.zip?generation=1743842376844696&alt=media" -> null
      - metadata            = {} -> null
      - name                = "dev--stressload-webservers.zip" -> null
      - output_name         = "dev--stressload-webservers.zip" -> null
      - self_link           = "https://www.googleapis.com/storage/v1/b/dev--cloud-function-bucket/o/dev--stressload-webservers.zip" -> null
      - source              = "./packages/stressload-webservers.zip" -> null
      - storage_class       = "STANDARD" -> null
      - temporary_hold      = false -> null
        # (5 unchanged attributes hidden)
    }

  # module.compute.google_compute_health_check.http will be destroyed
  - resource "google_compute_health_check" "http" {
      - check_interval_sec  = 5 -> null
      - creation_timestamp  = "2025-04-05T00:47:15.328-07:00" -> null
      - healthy_threshold   = 2 -> null
      - id                  = "projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check-us-west2" -> null
      - name                = "dev--http-health-check-us-west2" -> null
      - project             = "static-lead-454601-q1" -> null
      - self_link           = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check-us-west2" -> null
      - source_regions      = [] -> null
      - timeout_sec         = 5 -> null
      - type                = "HTTP" -> null
      - unhealthy_threshold = 2 -> null
        # (1 unchanged attribute hidden)

      - http_health_check {
          - port               = 80 -> null
          - proxy_header       = "NONE" -> null
          - request_path       = "/" -> null
            # (4 unchanged attributes hidden)
        }

      - log_config {
          - enable = false -> null
        }
    }

  # module.compute.google_compute_instance_template.web_server will be destroyed
  - resource "google_compute_instance_template" "web_server" {
      - can_ip_forward             = false -> null
      - creation_timestamp         = "2025-04-05T00:48:00.086-07:00" -> null
      - effective_labels           = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                         = "projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001" -> null
      - labels                     = {} -> null
      - machine_type               = "e2-micro" -> null
      - metadata                   = {
          - "startup-script" = <<-EOT
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
        } -> null
      - metadata_fingerprint       = "Mqk7vwDYD6M=" -> null
      - name                       = "dev--web-server-template--20250405074759047200000001" -> null
      - name_prefix                = "dev--web-server-template--" -> null
      - project                    = "static-lead-454601-q1" -> null
      - region                     = "us-west2" -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001" -> null
      - self_link_unique           = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001?uniqueId=5902721824568729280" -> null
      - tags                       = [
          - "http-server",
          - "ssh-access",
        ] -> null
      - terraform_labels           = {
          - "goog-terraform-provisioned" = "true"
        } -> null
        # (5 unchanged attributes hidden)

      - disk {
          - auto_delete            = true -> null
          - boot                   = true -> null
          - device_name            = "persistent-disk-0" -> null
          - disk_size_gb           = 0 -> null
          - disk_type              = "pd-standard" -> null
          - interface              = "SCSI" -> null
          - labels                 = {} -> null
          - mode                   = "READ_WRITE" -> null
          - provisioned_iops       = 0 -> null
          - provisioned_throughput = 0 -> null
          - resource_manager_tags  = {} -> null
          - resource_policies      = [] -> null
          - source_image           = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts" -> null
          - type                   = "PERSISTENT" -> null
            # (3 unchanged attributes hidden)
        }

      - network_interface {
          - internal_ipv6_prefix_length = 0 -> null
          - name                        = "nic0" -> null
          - network                     = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
          - queue_count                 = 0 -> null
          - subnetwork                  = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet" -> null
          - subnetwork_project          = "static-lead-454601-q1" -> null
            # (5 unchanged attributes hidden)
        }

      - scheduling {
          - automatic_restart           = true -> null
          - availability_domain         = 0 -> null
          - min_node_cpus               = 0 -> null
          - on_host_maintenance         = "MIGRATE" -> null
          - preemptible                 = false -> null
          - provisioning_model          = "STANDARD" -> null
            # (2 unchanged attributes hidden)
        }
    }

  # module.compute.google_compute_region_autoscaler.web_autoscaler will be destroyed
  - resource "google_compute_region_autoscaler" "web_autoscaler" {
      - creation_timestamp = "2025-04-05T00:48:23.314-07:00" -> null
      - id                 = "projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling" -> null
      - name               = "dev--web-autoscaling" -> null
      - project            = "static-lead-454601-q1" -> null
      - region             = "us-west2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling" -> null
      - target             = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroupManagers/dev--web-servers-group" -> null
        # (1 unchanged attribute hidden)

      - autoscaling_policy {
          - cooldown_period = 60 -> null
          - max_replicas    = 2 -> null
          - min_replicas    = 1 -> null
          - mode            = "ON" -> null

          - cpu_utilization {
              - predictive_method = "NONE" -> null
              - target            = 0.6 -> null
            }
        }
    }

  # module.compute.google_compute_region_instance_group_manager.web_servers will be destroyed
  - resource "google_compute_region_instance_group_manager" "web_servers" {
      - base_instance_name               = "dev--web-server" -> null
      - creation_timestamp               = "2025-04-05T00:48:02.222-07:00" -> null
      - distribution_policy_target_shape = "EVEN" -> null
      - distribution_policy_zones        = [
          - "us-west2-a",
          - "us-west2-b",
          - "us-west2-c",
        ] -> null
      - fingerprint                      = "Yz3w11C0UjQ=" -> null
      - id                               = "projects/static-lead-454601-q1/regions/us-west2/instanceGroupManagers/dev--web-servers-group" -> null
      - instance_group                   = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group" -> null
      - instance_group_manager_id        = 6780506401343889117 -> null
      - list_managed_instances_results   = "PAGELESS" -> null
      - name                             = "dev--web-servers-group" -> null
      - project                          = "static-lead-454601-q1" -> null
      - region                           = "us-west2" -> null
      - self_link                        = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroupManagers/dev--web-servers-group" -> null
      - status                           = [
          - {
              - all_instances_config = [
                  - {
                      - effective        = true
                        # (1 unchanged attribute hidden)
                    },
                ]
              - is_stable            = true
              - stateful             = [
                  - {
                      - has_stateful_config  = false
                      - per_instance_configs = [
                          - {
                              - all_effective = true
                            },
                        ]
                    },
                ]
              - version_target       = [
                  - {
                      - is_reached = true
                    },
                ]
            },
        ] -> null
      - target_pools                     = [] -> null
      - target_size                      = 2 -> null
      - target_stopped_size              = 0 -> null
      - target_suspended_size            = 0 -> null
      - wait_for_instances               = false -> null
      - wait_for_instances_status        = "STABLE" -> null
        # (1 unchanged attribute hidden)

      - instance_lifecycle_policy {
          - default_action_on_failure = "REPAIR" -> null
          - force_update_on_repair    = "NO" -> null
        }

      - standby_policy {
          - initial_delay_sec = 0 -> null
          - mode              = "MANUAL" -> null
        }

      - update_policy {
          - instance_redistribution_type   = "PROACTIVE" -> null
          - max_surge_fixed                = 3 -> null
          - max_surge_percent              = 0 -> null
          - max_unavailable_fixed          = 3 -> null
          - max_unavailable_percent        = 0 -> null
          - minimal_action                 = "REPLACE" -> null
          - replacement_method             = "SUBSTITUTE" -> null
          - type                           = "OPPORTUNISTIC" -> null
            # (1 unchanged attribute hidden)
        }

      - version {
          - instance_template = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001" -> null
            name              = null
        }
    }

  # module.firewall.google_compute_firewall.allow_http_https will be destroyed
  - resource "google_compute_firewall" "allow_http_https" {
      - creation_timestamp      = "2025-04-05T00:47:37.117-07:00" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/static-lead-454601-q1/global/firewalls/dev--allow-http-https" -> null
      - name                    = "dev--allow-http-https" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
      - priority                = 1000 -> null
      - project                 = "static-lead-454601-q1" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/firewalls/dev--allow-http-https" -> null
      - source_ranges           = [
          - "0.0.0.0/0",
        ] -> null
      - source_service_accounts = [] -> null
      - source_tags             = [] -> null
      - target_service_accounts = [] -> null
      - target_tags             = [] -> null
        # (1 unchanged attribute hidden)

      - allow {
          - ports    = [
              - "80",
              - "443",
            ] -> null
          - protocol = "tcp" -> null
        }
    }

  # module.firewall.google_compute_firewall.allow_ssh will be destroyed
  - resource "google_compute_firewall" "allow_ssh" {
      - creation_timestamp      = "2025-04-05T00:47:37.090-07:00" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-restricted" -> null
      - name                    = "dev--allow-ssh-restricted" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
      - priority                = 1000 -> null
      - project                 = "static-lead-454601-q1" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-restricted" -> null
      - source_ranges           = [
          - "10.0.0.0/8",
          - "35.235.240.0/20",
          - "68.109.187.94",
        ] -> null
      - source_service_accounts = [] -> null
      - source_tags             = [] -> null
      - target_service_accounts = [] -> null
      - target_tags             = [
          - "ssh-access",
        ] -> null
        # (1 unchanged attribute hidden)

      - allow {
          - ports    = [
              - "22",
            ] -> null
          - protocol = "tcp" -> null
        }
    }

  # module.firewall.google_compute_firewall.allow_ssh_iap will be destroyed
  - resource "google_compute_firewall" "allow_ssh_iap" {
      - creation_timestamp      = "2025-04-05T00:47:36.954-07:00" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-iap" -> null
      - name                    = "dev--allow-ssh-iap" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
      - priority                = 1000 -> null
      - project                 = "static-lead-454601-q1" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-iap" -> null
      - source_ranges           = [
          - "35.235.240.0/20",
        ] -> null
      - source_service_accounts = [] -> null
      - source_tags             = [] -> null
      - target_service_accounts = [] -> null
      - target_tags             = [
          - "ssh-access",
        ] -> null
        # (1 unchanged attribute hidden)

      - allow {
          - ports    = [
              - "22",
            ] -> null
          - protocol = "tcp" -> null
        }
    }

  # module.load_balancer.google_compute_backend_service.web_backend will be destroyed
  - resource "google_compute_backend_service" "web_backend" {
      - affinity_cookie_ttl_sec         = 0 -> null
      - connection_draining_timeout_sec = 300 -> null
      - creation_timestamp              = "2025-04-05T00:48:24.277-07:00" -> null
      - custom_request_headers          = [] -> null
      - custom_response_headers         = [] -> null
      - enable_cdn                      = false -> null
      - fingerprint                     = "31mxcukkUlI=" -> null
      - generated_id                    = 6710688877563960999 -> null
      - health_checks                   = [
          - "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check",
        ] -> null
      - id                              = "projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service" -> null
      - load_balancing_scheme           = "EXTERNAL" -> null
      - name                            = "dev--web-backend-service" -> null
      - port_name                       = "http" -> null
      - project                         = "static-lead-454601-q1" -> null
      - protocol                        = "HTTP" -> null
      - self_link                       = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service" -> null
      - session_affinity                = "NONE" -> null
      - timeout_sec                     = 30 -> null
        # (7 unchanged attributes hidden)

      - backend {
          - balancing_mode               = "UTILIZATION" -> null
          - capacity_scaler              = 1 -> null
          - group                        = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group" -> null
          - max_connections              = 0 -> null
          - max_connections_per_endpoint = 0 -> null
          - max_connections_per_instance = 0 -> null
          - max_rate                     = 0 -> null
          - max_rate_per_endpoint        = 0 -> null
          - max_rate_per_instance        = 0 -> null
          - max_utilization              = 0 -> null
            # (1 unchanged attribute hidden)
        }
    }

  # module.load_balancer.google_compute_global_forwarding_rule.http will be destroyed
  - resource "google_compute_global_forwarding_rule" "http" {
      - effective_labels      = {} -> null
      - forwarding_rule_id    = 9010661353678790246 -> null
      - id                    = "projects/static-lead-454601-q1/global/forwardingRules/dev--http-forwarding-rule" -> null
      - ip_address            = "34.8.19.233" -> null
      - ip_protocol           = "TCP" -> null
      - label_fingerprint     = "42WmSpB8rSM=" -> null
      - labels                = {} -> null
      - load_balancing_scheme = "EXTERNAL" -> null
      - name                  = "dev--http-forwarding-rule" -> null
      - network_tier          = "PREMIUM" -> null
      - port_range            = "80-80" -> null
      - project               = "static-lead-454601-q1" -> null
      - self_link             = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/forwardingRules/dev--http-forwarding-rule" -> null
      - source_ip_ranges      = [] -> null
      - target                = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy" -> null
      - terraform_labels      = {} -> null
        # (7 unchanged attributes hidden)
    }

  # module.load_balancer.google_compute_health_check.http will be destroyed
  - resource "google_compute_health_check" "http" {
      - check_interval_sec  = 5 -> null
      - creation_timestamp  = "2025-04-05T00:47:15.337-07:00" -> null
      - healthy_threshold   = 2 -> null
      - id                  = "projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check" -> null
      - name                = "dev--http-health-check" -> null
      - project             = "static-lead-454601-q1" -> null
      - self_link           = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check" -> null
      - source_regions      = [] -> null
      - timeout_sec         = 5 -> null
      - type                = "HTTP" -> null
      - unhealthy_threshold = 2 -> null
        # (1 unchanged attribute hidden)

      - http_health_check {
          - port               = 80 -> null
          - proxy_header       = "NONE" -> null
          - request_path       = "/" -> null
            # (4 unchanged attributes hidden)
        }

      - log_config {
          - enable = false -> null
        }
    }

  # module.load_balancer.google_compute_target_http_proxy.default will be destroyed
  - resource "google_compute_target_http_proxy" "default" {
      - creation_timestamp          = "2025-04-05T00:49:17.912-07:00" -> null
      - http_keep_alive_timeout_sec = 0 -> null
      - id                          = "projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy" -> null
      - name                        = "dev--web-http-proxy" -> null
      - project                     = "static-lead-454601-q1" -> null
      - proxy_bind                  = false -> null
      - proxy_id                    = 957541139024273042 -> null
      - self_link                   = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy" -> null
      - url_map                     = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map" -> null
        # (1 unchanged attribute hidden)
    }

  # module.load_balancer.google_compute_url_map.default will be destroyed
  - resource "google_compute_url_map" "default" {
      - creation_timestamp = "2025-04-05T00:49:06.582-07:00" -> null
      - default_service    = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service" -> null
      - fingerprint        = "zqYtr-A8LqU=" -> null
      - id                 = "projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map" -> null
      - map_id             = 5124259560514477725 -> null
      - name               = "dev--web-url-map" -> null
      - project            = "static-lead-454601-q1" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map" -> null
        # (1 unchanged attribute hidden)
    }

  # module.networking.google_compute_global_address.cloudsql_psa_range will be destroyed
  - resource "google_compute_global_address" "cloudsql_psa_range" {
      - address            = "10.96.0.0" -> null
      - address_type       = "INTERNAL" -> null
      - creation_timestamp = "2025-04-05T00:47:37.012-07:00" -> null
      - effective_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                 = "projects/static-lead-454601-q1/global/addresses/dev--cloudsql-psa-range" -> null
      - label_fingerprint  = "vezUS-42LLM=" -> null
      - labels             = {} -> null
      - name               = "dev--cloudsql-psa-range" -> null
      - network            = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
      - prefix_length      = 16 -> null
      - project            = "static-lead-454601-q1" -> null
      - purpose            = "VPC_PEERING" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/addresses/dev--cloudsql-psa-range" -> null
      - terraform_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
        # (2 unchanged attributes hidden)
    }

  # module.networking.google_compute_network.vpc_network will be destroyed
  - resource "google_compute_network" "vpc_network" {
      - auto_create_subnetworks                   = false -> null
      - bgp_always_compare_med                    = false -> null
      - bgp_best_path_selection_mode              = "LEGACY" -> null
      - delete_default_routes_on_create           = false -> null
      - enable_ula_internal_ipv6                  = false -> null
      - id                                        = "projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
      - mtu                                       = 0 -> null
      - name                                      = "dev--webapp-vpc" -> null
      - network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL" -> null
      - network_id                                = "7183538912560504556" -> null
      - numeric_id                                = "7183538912560504556" -> null
      - project                                   = "static-lead-454601-q1" -> null
      - routing_mode                              = "REGIONAL" -> null
      - self_link                                 = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
        # (5 unchanged attributes hidden)
    }

  # module.networking.google_compute_router.nat_router will be destroyed
  - resource "google_compute_router" "nat_router" {
      - creation_timestamp            = "2025-04-05T00:47:37.173-07:00" -> null
      - encrypted_interconnect_router = false -> null
      - id                            = "projects/static-lead-454601-q1/regions/us-west2/routers/dev--webapp-router" -> null
      - name                          = "dev--webapp-router" -> null
      - network                       = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
      - project                       = "static-lead-454601-q1" -> null
      - region                        = "us-west2" -> null
      - self_link                     = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/routers/dev--webapp-router" -> null
        # (1 unchanged attribute hidden)
    }

  # module.networking.google_compute_router_nat.nat_config will be destroyed
  - resource "google_compute_router_nat" "nat_config" {
      - auto_network_tier                   = "PREMIUM" -> null
      - drain_nat_ips                       = [] -> null
      - enable_dynamic_port_allocation      = false -> null
      - enable_endpoint_independent_mapping = true -> null
      - endpoint_types                      = [
          - "ENDPOINT_TYPE_VM",
        ] -> null
      - icmp_idle_timeout_sec               = 30 -> null
      - id                                  = "static-lead-454601-q1/us-west2/dev--webapp-router/dev--webapp-nat-config" -> null
      - max_ports_per_vm                    = 0 -> null
      - min_ports_per_vm                    = 0 -> null
      - name                                = "dev--webapp-nat-config" -> null
      - nat_ip_allocate_option              = "AUTO_ONLY" -> null
      - nat_ips                             = [] -> null
      - project                             = "static-lead-454601-q1" -> null
      - region                              = "us-west2" -> null
      - router                              = "dev--webapp-router" -> null
      - source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES" -> null
      - tcp_established_idle_timeout_sec    = 1200 -> null
      - tcp_time_wait_timeout_sec           = 120 -> null
      - tcp_transitory_idle_timeout_sec     = 30 -> null
      - udp_idle_timeout_sec                = 30 -> null

      - log_config {
          - enable = true -> null
          - filter = "ERRORS_ONLY" -> null
        }
    }

  # module.networking.google_compute_subnetwork.subnet will be destroyed
  - resource "google_compute_subnetwork" "subnet" {
      - creation_timestamp         = "2025-04-05T00:47:37.794-07:00" -> null
      - enable_flow_logs           = false -> null
      - gateway_address            = "10.100.0.1" -> null
      - id                         = "projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet" -> null
      - ip_cidr_range              = "10.100.0.0/24" -> null
      - name                       = "dev--webapp-subnet" -> null
      - network                    = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
      - private_ip_google_access   = true -> null
      - private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS" -> null
      - project                    = "static-lead-454601-q1" -> null
      - purpose                    = "PRIVATE" -> null
      - region                     = "us-west2" -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet" -> null
      - stack_type                 = "IPV4_ONLY" -> null
      - subnetwork_id              = 7040581630487781110 -> null
        # (9 unchanged attributes hidden)
    }

  # module.networking.google_project_service.servicenetworking will be destroyed
  - resource "google_project_service" "servicenetworking" {
      - disable_on_destroy = true -> null
      - id                 = "static-lead-454601-q1/servicenetworking.googleapis.com" -> null
      - project            = "static-lead-454601-q1" -> null
      - service            = "servicenetworking.googleapis.com" -> null
    }

  # module.networking.google_service_networking_connection.cloudsql_psa_connection will be destroyed
  - resource "google_service_networking_connection" "cloudsql_psa_connection" {
      - id                      = "projects%2Fstatic-lead-454601-q1%2Fglobal%2Fnetworks%2Fdev--webapp-vpc:servicenetworking.googleapis.com" -> null
      - network                 = "projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
      - peering                 = "servicenetworking-googleapis-com" -> null
      - reserved_peering_ranges = [
          - "dev--cloudsql-psa-range",
        ] -> null
      - service                 = "servicenetworking.googleapis.com" -> null
    }

  # module.profiles.google_project_iam_member.cli_admin_logging_viewer will be destroyed
  - resource "google_project_iam_member" "cli_admin_logging_viewer" {
      - etag    = "BwYyAzciVSU=" -> null
      - id      = "static-lead-454601-q1/roles/logging.viewer/serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - project = "static-lead-454601-q1" -> null
      - role    = "roles/logging.viewer" -> null
    }

  # module.profiles.google_project_iam_member.cli_admin_storage_admin will be destroyed
  - resource "google_project_iam_member" "cli_admin_storage_admin" {
      - etag    = "BwYyAzciVSU=" -> null
      - id      = "static-lead-454601-q1/roles/storage.admin/serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - project = "static-lead-454601-q1" -> null
      - role    = "roles/storage.admin" -> null
    }

  # module.profiles.google_project_iam_member.cloud_function_compute_viewer[0] will be destroyed
  - resource "google_project_iam_member" "cloud_function_compute_viewer" {
      - etag    = "BwYyAzciVSU=" -> null
      - id      = "static-lead-454601-q1/roles/compute.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - project = "static-lead-454601-q1" -> null
      - role    = "roles/compute.viewer" -> null
    }

  # module.profiles.google_project_iam_member.cloud_function_logging_viewer[0] will be destroyed
  - resource "google_project_iam_member" "cloud_function_logging_viewer" {
      - etag    = "BwYyAzciVSU=" -> null
      - id      = "static-lead-454601-q1/roles/logging.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - project = "static-lead-454601-q1" -> null
      - role    = "roles/logging.viewer" -> null
    }

  # module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0] will be destroyed
  - resource "google_project_iam_member" "cloud_function_monitoring_viewer" {
      - etag    = "BwYyAzciVSU=" -> null
      - id      = "static-lead-454601-q1/roles/monitoring.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - project = "static-lead-454601-q1" -> null
      - role    = "roles/monitoring.viewer" -> null
    }

  # module.profiles.google_project_iam_member.compute_viewer will be destroyed
  - resource "google_project_iam_member" "compute_viewer" {
      - etag    = "BwYyAzciVSU=" -> null
      - id      = "static-lead-454601-q1/roles/compute.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - project = "static-lead-454601-q1" -> null
      - role    = "roles/compute.viewer" -> null
    }

  # module.profiles.google_project_iam_member.logging_viewer will be destroyed
  - resource "google_project_iam_member" "logging_viewer" {
      - etag    = "BwYyAzciVSU=" -> null
      - id      = "static-lead-454601-q1/roles/logging.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - project = "static-lead-454601-q1" -> null
      - role    = "roles/logging.viewer" -> null
    }

  # module.profiles.google_project_iam_member.monitoring_viewer will be destroyed
  - resource "google_project_iam_member" "monitoring_viewer" {
      - etag    = "BwYyAzciVSU=" -> null
      - id      = "static-lead-454601-q1/roles/monitoring.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - project = "static-lead-454601-q1" -> null
      - role    = "roles/monitoring.viewer" -> null
    }

  # module.profiles.google_service_account.cloud_function[0] will be destroyed
  - resource "google_service_account" "cloud_function" {
      - account_id   = "dev--ro--cloud-function" -> null
      - disabled     = false -> null
      - display_name = "Cloud Function SA (Stress Test)" -> null
      - email        = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - id           = "projects/static-lead-454601-q1/serviceAccounts/dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - member       = "serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - name         = "projects/static-lead-454601-q1/serviceAccounts/dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - project      = "static-lead-454601-q1" -> null
      - unique_id    = "106698488519359597344" -> null
        # (1 unchanged attribute hidden)
    }

  # module.profiles.google_service_account.read_only will be destroyed
  - resource "google_service_account" "read_only" {
      - account_id   = "dev--ro--service-account" -> null
      - disabled     = false -> null
      - display_name = "Read-Only Service Account for dev" -> null
      - email        = "dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - id           = "projects/static-lead-454601-q1/serviceAccounts/dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - member       = "serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - name         = "projects/static-lead-454601-q1/serviceAccounts/dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
      - project      = "static-lead-454601-q1" -> null
      - unique_id    = "106725142199856657740" -> null
        # (1 unchanged attribute hidden)
    }

Plan: 0 to add, 0 to change, 31 to destroy.

Changes to Outputs:
  - cloud_function_bucket                     = "dev--cloud-function-bucket" -> null
  - cloud_function_service_account_email      = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
  - cloud_function_service_account_unique_id  = "106698488519359597344" -> null
  - cloud_function_upload_target              = "module.cloud_function[0].google_storage_bucket_object.function_archive" -> null
  - cloudsql_psa_range_name                   = "dev--cloudsql-psa-range" -> null
  - compute_instance_template                 = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001" -> null
  - compute_instance_type                     = "e2-micro" -> null
  - compute_web_autoscaler_name               = "dev--web-autoscaling" -> null
  - compute_web_server_ip                     = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group" -> null
  - compute_web_servers_group                 = "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group" -> null
  - environment_config                        = {
      - description = "Development environment"
      - id          = "dev"
      - name        = "development"
      - policies    = {
          - autoscaling = "basic"
          - stressload  = "low"
        }
      - region      = "west"
      - type        = "micro"
    } -> null
  - firewall_console_ips                      = [
      - "35.235.240.0/20",
    ] -> null
  - firewall_devops_ips                       = [
      - "68.109.187.94",
    ] -> null
  - firewall_private_ips                      = [
      - "10.0.0.0/8",
    ] -> null
  - firewall_public_http_ranges               = [
      - "0.0.0.0/0",
    ] -> null
  - gcp_project_config                        = {
      - credentials = ""
      - project_id  = "static-lead-454601-q1"
      - provider    = "gcp"
      - regions     = {
          - central = "us-central2"
          - east    = "us-east2"
          - west    = "us-west2"
        }
      - services    = {
          - cloud_function    = {
              - archive_name   = "stressload-webservers.zip"
              - archive_path   = "./packages"
              - auto_deploy    = false
              - bucket_name    = "cloud-function-bucket"
              - description    = "Stub Cloud Function for stress testing framework"
              - enable         = true
              - entry_point    = "main"
              - env            = {
                  - TARGET_URL = ""
                }
              - event_type     = "google.cloud.functions.v2.eventTypes.EVENT_TRIGGERED"
              - force_destroy  = true
              - invoker_member = "allUsers"
              - invoker_role   = "roles/cloudfunctions.invoker"
              - memory         = "256M"
              - name           = "webapp-stress-tester"
              - pubsub_topic   = null
              - runtime        = "python311"
              - timeout        = 60
            }
          - compute_resources = {
              - base_instance_name            = "web-server"
              - health_check                  = {
                  - interval = 5
                  - name     = "http-health-check"
                  - port     = 80
                  - timeout  = 5
                }
              - instance_group_name           = "web-servers-group"
              - instance_tags                 = [
                  - "ssh-access",
                  - "http-server",
                ]
              - instance_template_name_prefix = "web-server-template--"
              - source_image                  = "ubuntu-os-cloud/ubuntu-2004-lts"
              - startup_script_path           = "./scripts/configure/apache-webserver.shell"
            }
          - firewall_rules    = {
              - allow_http_https   = {
                  - name     = "allow-http-https"
                  - ports    = [
                      - "80",
                      - "443",
                    ]
                  - protocol = "tcp"
                }
              - allow_ssh          = {
                  - name        = "allow-ssh-restricted"
                  - ports       = [
                      - "22",
                    ]
                  - protocol    = "tcp"
                  - target_tags = [
                      - "ssh-access",
                    ]
                }
              - allow_ssh_iap      = {
                  - name        = "allow-ssh-iap"
                  - ports       = [
                      - "22",
                    ]
                  - protocol    = "tcp"
                  - target_tags = [
                      - "ssh-access",
                    ]
                }
              - public_http_ranges = [
                  - "0.0.0.0/0",
                ]
            }
          - health_check      = {
              - name = "http-health-check"
            }
          - http_forwarding   = {
              - name = "http-forwarding-rule"
            }
          - load_balancer     = {
              - health_check    = {
                  - interval = 5
                  - name     = "http-health-check"
                  - port     = 80
                  - timeout  = 5
                }
              - http_forwarding = {
                  - name       = "http-forwarding-rule"
                  - port_range = "80"
                  - scheme     = "EXTERNAL"
                }
              - http_proxy      = {
                  - name = "web-http-proxy"
                }
              - url_map         = {
                  - name = "web-url-map"
                }
              - web_backend     = {
                  - name     = "web-backend-service"
                  - protocol = "HTTP"
                  - timeout  = 30
                }
            }
          - networking        = {
              - management              = {
                  - enable                   = false
                  - private_ip_google_access = true
                  - subnet_cidr              = "10.90.0.0/24"
                  - subnet_name              = "mgmt-subnet"
                  - vpc_name                 = "mgmt-vpc"
                }
              - nat                     = {
                  - config_name        = "webapp-nat-config"
                  - enable_nat_logging = true
                  - nat_logging_filter = "ERRORS_ONLY"
                  - router_name        = "webapp-router"
                  - timeouts           = {
                      - icmp_idle_sec       = 30
                      - tcp_established_sec = 1200
                      - tcp_transitory_sec  = 30
                      - udp_idle_sec        = 30
                    }
                }
              - psa_range_name          = "cloudsql-psa-range"
              - psa_range_prefix_length = 16
              - subnet_cidr             = "10.100.0.0/24"
              - subnet_name             = "webapp-subnet"
              - vpc_network_name        = "webapp-vpc"
            }
          - web_autoscaling   = {
              - name = "web-autoscaling"
            }
          - web_backend       = {
              - name = "web-backend-service"
            }
        }
      - types       = {
          - medium   = "e2-medium"
          - micro    = "e2-micro"
          - standard = "n1-standard-1"
        }
    } -> null
  - http_forwarding_rule_name                 = "dev--http-forwarding-rule" -> null
  - http_health_check_name                    = "dev--http-health-check" -> null
  - load_balancer_ip                          = "34.8.19.233" -> null
  - nat_name                                  = "dev--webapp-nat-config" -> null
  - project_id                                = "static-lead-454601-q1" -> null
  - readonly_service_account_email            = "dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com" -> null
  - readonly_service_account_id               = "106725142199856657740" -> null
  - region                                    = "us-west2" -> null
  - router_name                               = "dev--webapp-router" -> null
  - stressload_config                         = {
      - duration = 60
      - interval = 0.04
      - requests = 10000
      - threads  = 250
    } -> null
  - stressload_function_bucket                = "dev--cloud-function-bucket" -> null
  - stressload_function_name                  = "dev--webapp-stress-tester" -> null
  - stressload_function_region                = "us-west2" -> null
  - stressload_function_service_account_email = "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com" -> null
  - stressload_key                            = "low" -> null
  - stressload_log_level                      = "info" -> null
  - subnet_id                                 = "projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet" -> null
  - vpc_network_id                            = "projects/static-lead-454601-q1/global/networks/dev--webapp-vpc" -> null
  - web_backend_service_name                  = "dev--web-backend-service" -> null
  - workspace                                 = "dev" -> null
```

```console
Do you really want to destroy all resources in workspace "dev"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

```hcl
module.profiles.google_project_iam_member.compute_viewer: Destroying... [id=static-lead-454601-q1/roles/compute.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0]: Destroying... [id=static-lead-454601-q1/roles/monitoring.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.logging_viewer: Destroying... [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_compute_viewer[0]: Destroying... [id=static-lead-454601-q1/roles/compute.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.firewall.google_compute_firewall.allow_ssh: Destroying... [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-restricted]
module.cloud_function[0].google_storage_bucket_object.function_archive[0]: Destroying... [id=dev--cloud-function-bucket-dev--stressload-webservers.zip]
module.networking.google_compute_router_nat.nat_config: Destroying... [id=static-lead-454601-q1/us-west2/dev--webapp-router/dev--webapp-nat-config]
module.load_balancer.google_compute_global_forwarding_rule.http: Destroying... [id=projects/static-lead-454601-q1/global/forwardingRules/dev--http-forwarding-rule]
module.compute.google_compute_health_check.http: Destroying... [id=projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check-us-west2]
module.compute.google_compute_region_autoscaler.web_autoscaler: Destroying... [id=projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling]
module.cloud_function[0].google_storage_bucket_object.function_archive[0]: Destruction complete after 1s
module.profiles.google_project_iam_member.cli_admin_logging_viewer: Destroying... [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cli_admin_logging_viewer: Destruction complete after 7s
module.profiles.google_project_iam_member.monitoring_viewer: Destroying... [id=static-lead-454601-q1/roles/monitoring.viewer/serviceAccount:dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0]: Destruction complete after 8s
module.networking.google_service_networking_connection.cloudsql_psa_connection: Destroying... [id=projects%2Fstatic-lead-454601-q1%2Fglobal%2Fnetworks%2Fdev--webapp-vpc:servicenetworking.googleapis.com]
module.profiles.google_project_iam_member.cloud_function_compute_viewer[0]: Destruction complete after 8s
module.profiles.google_project_iam_member.cli_admin_storage_admin: Destroying... [id=static-lead-454601-q1/roles/storage.admin/serviceAccount:gcp-cli-admin@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.compute_viewer: Destruction complete after 9s
module.firewall.google_compute_firewall.allow_http_https: Destroying... [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-http-https]
module.profiles.google_project_iam_member.logging_viewer: Destruction complete after 9s
module.firewall.google_compute_firewall.allow_ssh_iap: Destroying... [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-iap]
module.firewall.google_compute_firewall.allow_ssh: Still destroying... [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-restricted, 10s elapsed]
module.networking.google_compute_router_nat.nat_config: Still destroying... [id=static-lead-454601-q1/us-west2/dev--webapp-router/dev--webapp-nat-config, 10s elapsed]
module.load_balancer.google_compute_global_forwarding_rule.http: Still destroying... [id=projects/static-lead-454601-q1/global/forwardingRules/dev--http-forwarding-rule, 10s elapsed]
module.compute.google_compute_health_check.http: Still destroying... [id=projects/static-lead-454601-q1/global/h...Checks/dev--http-health-check-us-west2, 10s elapsed]
module.compute.google_compute_region_autoscaler.web_autoscaler: Still destroying... [id=projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling, 10s elapsed]
module.compute.google_compute_region_autoscaler.web_autoscaler: Destruction complete after 11s
module.profiles.google_project_iam_member.cloud_function_logging_viewer[0]: Destroying... [id=static-lead-454601-q1/roles/logging.viewer/serviceAccount:dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.networking.google_compute_router_nat.nat_config: Destruction complete after 11s
module.cloud_function[0].google_storage_bucket.function_bucket: Destroying... [id=dev--cloud-function-bucket]
module.firewall.google_compute_firewall.allow_ssh: Destruction complete after 11s
module.networking.google_compute_router.nat_router: Destroying... [id=projects/static-lead-454601-q1/regions/us-west2/routers/dev--webapp-router]
module.compute.google_compute_health_check.http: Destruction complete after 11s
module.cloud_function[0].google_storage_bucket.function_bucket: Destruction complete after 1s
module.profiles.google_project_iam_member.cloud_function_logging_viewer[0]: Destruction complete after 4s
module.profiles.google_service_account.cloud_function[0]: Destroying... [id=projects/static-lead-454601-q1/serviceAccounts/dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.monitoring_viewer: Destruction complete after 8s
module.profiles.google_service_account.read_only: Destroying... [id=projects/static-lead-454601-q1/serviceAccounts/dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cli_admin_storage_admin: Destruction complete after 8s
module.profiles.google_service_account.cloud_function[0]: Destruction complete after 1s
module.profiles.google_service_account.read_only: Destruction complete after 0s
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still destroying... [id=projects%2Fstatic-lead-454601-q1%2Fglob...p-vpc:servicenetworking.googleapis.com, 10s elapsed]
module.firewall.google_compute_firewall.allow_http_https: Still destroying... [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-http-https, 10s elapsed]
module.firewall.google_compute_firewall.allow_ssh_iap: Still destroying... [id=projects/static-lead-454601-q1/global/firewalls/dev--allow-ssh-iap, 10s elapsed]
module.firewall.google_compute_firewall.allow_ssh_iap: Destruction complete after 10s
module.firewall.google_compute_firewall.allow_http_https: Destruction complete after 11s
module.load_balancer.google_compute_global_forwarding_rule.http: Still destroying... [id=projects/static-lead-454601-q1/global/forwardingRules/dev--http-forwarding-rule, 20s elapsed]
module.networking.google_compute_router.nat_router: Still destroying... [id=projects/static-lead-454601-q1/regions/us-west2/routers/dev--webapp-router, 10s elapsed]
module.load_balancer.google_compute_global_forwarding_rule.http: Destruction complete after 21s
module.networking.google_compute_router.nat_router: Destruction complete after 11s
module.load_balancer.google_compute_target_http_proxy.default: Destroying... [id=projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still destroying... [id=projects%2Fstatic-lead-454601-q1%2Fglob...p-vpc:servicenetworking.googleapis.com, 20s elapsed]
module.load_balancer.google_compute_target_http_proxy.default: Still destroying... [id=projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy, 10s elapsed]
module.load_balancer.google_compute_target_http_proxy.default: Destruction complete after 11s
module.load_balancer.google_compute_url_map.default: Destroying... [id=projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still destroying... [id=projects%2Fstatic-lead-454601-q1%2Fglob...p-vpc:servicenetworking.googleapis.com, 30s elapsed]
module.load_balancer.google_compute_url_map.default: Still destroying... [id=projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map, 10s elapsed]
module.load_balancer.google_compute_url_map.default: Destruction complete after 11s
module.load_balancer.google_compute_backend_service.web_backend: Destroying... [id=projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still destroying... [id=projects%2Fstatic-lead-454601-q1%2Fglob...p-vpc:servicenetworking.googleapis.com, 40s elapsed]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Destruction complete after 42s
module.networking.google_project_service.servicenetworking: Destroying... [id=static-lead-454601-q1/servicenetworking.googleapis.com]
module.networking.google_compute_global_address.cloudsql_psa_range: Destroying... [id=projects/static-lead-454601-q1/global/addresses/dev--cloudsql-psa-range]
module.load_balancer.google_compute_backend_service.web_backend: Still destroying... [id=projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service, 10s elapsed]
module.networking.google_project_service.servicenetworking: Still destroying... [id=static-lead-454601-q1/servicenetworking.googleapis.com, 10s elapsed]
module.networking.google_compute_global_address.cloudsql_psa_range: Still destroying... [id=projects/static-lead-454601-q1/global/addresses/dev--cloudsql-psa-range, 10s elapsed]
module.networking.google_compute_global_address.cloudsql_psa_range: Destruction complete after 11s
module.networking.google_project_service.servicenetworking: Destruction complete after 11s
module.load_balancer.google_compute_backend_service.web_backend: Still destroying... [id=projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service, 20s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still destroying... [id=projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service, 30s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still destroying... [id=projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service, 40s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Destruction complete after 42s
module.load_balancer.google_compute_health_check.http: Destroying... [id=projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check]
module.compute.google_compute_region_instance_group_manager.web_servers: Destroying... [id=projects/static-lead-454601-q1/regions/us-west2/instanceGroupManagers/dev--web-servers-group]
module.load_balancer.google_compute_health_check.http: Still destroying... [id=projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check, 10s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/static-lead-454601-q1/regions/...ceGroupManagers/dev--web-servers-group, 10s elapsed]
module.load_balancer.google_compute_health_check.http: Destruction complete after 11s
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/static-lead-454601-q1/regions/...ceGroupManagers/dev--web-servers-group, 20s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/static-lead-454601-q1/regions/...ceGroupManagers/dev--web-servers-group, 30s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/static-lead-454601-q1/regions/...ceGroupManagers/dev--web-servers-group, 40s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/static-lead-454601-q1/regions/...ceGroupManagers/dev--web-servers-group, 50s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/static-lead-454601-q1/regions/...ceGroupManagers/dev--web-servers-group, 1m0s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/static-lead-454601-q1/regions/...ceGroupManagers/dev--web-servers-group, 1m10s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/static-lead-454601-q1/regions/...ceGroupManagers/dev--web-servers-group, 1m20s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Destruction complete after 1m22s
module.compute.google_compute_instance_template.web_server: Destroying... [id=projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001]
module.compute.google_compute_instance_template.web_server: Still destroying... [id=projects/static-lead-454601-q1/global/i...r-template--20250405074759047200000001, 10s elapsed]
module.compute.google_compute_instance_template.web_server: Destruction complete after 11s
module.networking.google_compute_subnetwork.subnet: Destroying... [id=projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet]
module.networking.google_compute_subnetwork.subnet: Still destroying... [id=projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet, 10s elapsed]
module.networking.google_compute_subnetwork.subnet: Still destroying... [id=projects/static-lead-454601-q1/regions/us-west2/subnetworks/dev--webapp-subnet, 20s elapsed]
module.networking.google_compute_subnetwork.subnet: Destruction complete after 21s
module.networking.google_compute_network.vpc_network: Destroying... [id=projects/static-lead-454601-q1/global/networks/dev--webapp-vpc]
module.networking.google_compute_network.vpc_network: Still destroying... [id=projects/static-lead-454601-q1/global/networks/dev--webapp-vpc, 10s elapsed]
module.networking.google_compute_network.vpc_network: Still destroying... [id=projects/static-lead-454601-q1/global/networks/dev--webapp-vpc, 20s elapsed]
module.networking.google_compute_network.vpc_network: Destruction complete after 21s
```

```console
Destroy complete! Resources: 31 destroyed.
```
