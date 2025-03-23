```terraform
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

```terraform
$ terraform plan ;

module.compute.data.google_compute_zones.available: Reading...
module.compute.data.google_compute_zones.available: Read complete after 1s [id=projects/<gcp-project-name>/regions/us-west2]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
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
      + project             = "<gcp-project-name>"
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

                # Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1078-gcp x86_64)

                #  * Documentation:  https://help.ubuntu.com
                #  * Management:     https://landscape.canonical.com
                #  * Support:        https://ubuntu.com/pro

                #  System information as of Mon Apr  7 15:39:01 UTC 2025

                #   System load:  0.0               Processes:             106
                #   Usage of /:   22.6% of 9.51GB   Users logged in:       0
                #   Memory usage: 24%               IPv4 address for ens4: 10.100.0.2
                #   Swap usage:   0%

                # Expanded Security Maintenance for Applications is not enabled.

                # 21 updates can be applied immediately.
                # 19 of these updates are standard security updates.
                # To see these additional updates run: apt list --upgradable

                # Enable ESM Apps to receive additional future security updates.
                # See https://ubuntu.com/esm or run: sudo pro status

                # The programs included with the Ubuntu system are free software;
                # the exact distribution terms for each program are described in the
                # individual files in /usr/share/doc/*/copyright.

                # Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
                # applicable law.

                # devops_workflows@dev--web-server-840m:~$ curl --head localhost ;
                # HTTP/1.1 200 OK
                # Date: Mon, 07 Apr 2025 15:52:27 GMT
                # Server: Apache/2.4.41 (Ubuntu)
                # Last-Modified: Mon, 07 Apr 2025 15:31:19 GMT
                # ETag: "3b-63231ed7cb253"
                # Accept-Ranges: bytes
                # Content-Length: 59
                # Content-Type: text/html
            EOT
        }
      + metadata_fingerprint = (known after apply)
      + name                 = (known after apply)
      + name_prefix          = "dev--web-server-template--"
      + project              = "<gcp-project-name>"
      + region               = "us-west2"
      + self_link            = (known after apply)
      + self_link_unique     = (known after apply)
      + tags                 = [
          + "dev--http-server",
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
      + project            = "<gcp-project-name>"
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
      + project                          = "<gcp-project-name>"
      + region                           = "us-west2"
      + self_link                        = (known after apply)
      + status                           = (known after apply)
      + target_size                      = 1
      + target_stopped_size              = (known after apply)
      + target_suspended_size            = (known after apply)
      + wait_for_instances               = false
      + wait_for_instances_status        = "STABLE"

      + instance_lifecycle_policy {
          + default_action_on_failure = "REPAIR"
          + force_update_on_repair    = "NO"
        }

      + standby_policy (known after apply)

      + update_policy {
          + max_surge_fixed       = 3
          + max_unavailable_fixed = 0
          + minimal_action        = "REPLACE"
          + type                  = "OPPORTUNISTIC"
        }

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
      + project            = "<gcp-project-name>"
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
      + project            = "<gcp-project-name>"
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
      + project            = "<gcp-project-name>"
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
      + project                         = "<gcp-project-name>"
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
      + project               = "<gcp-project-name>"
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
      + project             = "<gcp-project-name>"
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
      + project            = "<gcp-project-name>"
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
      + project            = "<gcp-project-name>"
      + self_link          = (known after apply)
    }

  # module.networking.google_compute_global_address.cloudsql_psa_range will be created
  + resource "google_compute_global_address" "cloudsql_psa_range" {
      + address            = (known after apply)
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "dev--networking"            = "true"
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + labels             = {
          + "dev--networking" = "true"
        }
      + name               = "dev--cloudsql-psa-range"
      + network            = (known after apply)
      + prefix_length      = 16
      + project            = "<gcp-project-name>"
      + purpose            = "VPC_PEERING"
      + self_link          = (known after apply)
      + terraform_labels   = {
          + "dev--networking"            = "true"
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
      + project                                   = "<gcp-project-name>"
      + routing_mode                              = (known after apply)
      + self_link                                 = (known after apply)
    }

  # module.networking.google_compute_router.nat_router will be created
  + resource "google_compute_router" "nat_router" {
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "dev--webapp-router"
      + network            = (known after apply)
      + project            = "<gcp-project-name>"
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
      + project                             = "<gcp-project-name>"
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
      + project                    = "<gcp-project-name>"
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
      + project            = "<gcp-project-name>"
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
      + member  = "serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com"
      + project = "<gcp-project-name>"
      + role    = "roles/logging.viewer"
    }

  # module.profiles.google_project_iam_member.cli_admin_storage_admin will be created
  + resource "google_project_iam_member" "cli_admin_storage_admin" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com"
      + project = "<gcp-project-name>"
      + role    = "roles/storage.admin"
    }

  # module.profiles.google_project_iam_member.cloud_function_compute_viewer[0] will be created
  + resource "google_project_iam_member" "cloud_function_compute_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com"
      + project = "<gcp-project-name>"
      + role    = "roles/compute.viewer"
    }

  # module.profiles.google_project_iam_member.cloud_function_logging_viewer[0] will be created
  + resource "google_project_iam_member" "cloud_function_logging_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com"
      + project = "<gcp-project-name>"
      + role    = "roles/logging.viewer"
    }

  # module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0] will be created
  + resource "google_project_iam_member" "cloud_function_monitoring_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com"
      + project = "<gcp-project-name>"
      + role    = "roles/monitoring.viewer"
    }

  # module.profiles.google_project_iam_member.compute_viewer will be created
  + resource "google_project_iam_member" "compute_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com"
      + project = "<gcp-project-name>"
      + role    = "roles/compute.viewer"
    }

  # module.profiles.google_project_iam_member.logging_viewer will be created
  + resource "google_project_iam_member" "logging_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com"
      + project = "<gcp-project-name>"
      + role    = "roles/logging.viewer"
    }

  # module.profiles.google_project_iam_member.monitoring_viewer will be created
  + resource "google_project_iam_member" "monitoring_viewer" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com"
      + project = "<gcp-project-name>"
      + role    = "roles/monitoring.viewer"
    }

  # module.profiles.google_service_account.cloud_function[0] will be created
  + resource "google_service_account" "cloud_function" {
      + account_id   = "dev--ro--cloud-function"
      + disabled     = false
      + display_name = "Cloud Function SA (Stress Test)"
      + email        = "dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com"
      + id           = (known after apply)
      + member       = "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com"
      + name         = (known after apply)
      + project      = "<gcp-project-name>"
      + unique_id    = (known after apply)
    }

  # module.profiles.google_service_account.read_only will be created
  + resource "google_service_account" "read_only" {
      + account_id   = "dev--ro--service-account"
      + disabled     = false
      + display_name = "Read-Only Service Account for dev"
      + email        = "dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com"
      + id           = (known after apply)
      + member       = "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com"
      + name         = (known after apply)
      + project      = "<gcp-project-name>"
      + unique_id    = (known after apply)
    }

Plan: 31 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cloud_function_bucket                     = "dev--cloud-function-bucket"
  + cloud_function_service_account_email      = "dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com"
  + cloud_function_service_account_unique_id  = (known after apply)
  + cloud_function_tags                       = []
  + cloud_function_upload_target              = "module.cloud_function[0].google_storage_bucket_object.function_archive"
  + cloudsql_psa_range_name                   = "dev--cloudsql-psa-range"
  + compute_instance_tags                     = [
      + "ssh-access",
      + "dev--http-server",
    ]
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
  + firewall_allow_ssh_iap_tags               = [
      + "ssh-access",
    ]
  + firewall_allow_ssh_tags                   = [
      + "ssh-access",
    ]
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
      + project_id  = "<gcp-project-name>"
      + provider    = "gcp"
      + regions     = {
          + central = "us-central2"
          + east    = "us-east2"
          + west    = "us-west2"
        }
      + services    = [
          + "cloud_function",
          + "compute_resources",
          + "firewall_rules",
          + "health_check",
          + "http_forwarding",
          + "load_balancer",
          + "networking",
          + "web_autoscaling",
          + "web_backend",
        ]
      + types       = {
          + medium   = "e2-medium"
          + micro    = "e2-micro"
          + standard = "n1-standard-1"
        }
    }
  + http_forwarding_rule_name                 = "dev--http-forwarding-rule"
  + http_health_check_name                    = "dev--http-health-check"
  + load_balancer_ip                          = (known after apply)
  + load_balancer_tags                        = [
      + "dev--load-balancer",
    ]
  + nat_name                                  = "dev--webapp-nat-config"
  + networking_tags                           = [
      + "dev--networking",
    ]
  + profiles_tags                             = [
      + "dev--service-accounts",
    ]
  + project_id                                = "<gcp-project-name>"
  + readonly_service_account_email            = "dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com"
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
  + stressload_function_service_account_email = "dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com"
  + stressload_key                            = "low"
  + stressload_log_level                      = "info"
  + subnet_id                                 = (known after apply)
  + vpc_network_id                            = (known after apply)
  + web_backend_service_name                  = "dev--web-backend-service"
  + workspace                                 = "dev"

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
