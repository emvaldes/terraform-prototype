
```terraform
$ terraform destroy ;

module.compute.data.google_compute_zones.available: Reading...
module.profiles.google_project_iam_member.cli_admin_storage_admin: Refreshing state... [id=<gcp-project-name>/roles/storage.admin/serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com]
module.networking.google_project_service.servicenetworking: Refreshing state... [id=<gcp-project-name>/servicenetworking.googleapis.com]
module.profiles.google_service_account.read_only: Refreshing state... [id=projects/<gcp-project-name>/serviceAccounts/dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cli_admin_logging_viewer: Refreshing state... [id=<gcp-project-name>/roles/logging.viewer/serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com]
module.networking.google_compute_network.vpc_network: Refreshing state... [id=projects/<gcp-project-name>/global/networks/dev--webapp-vpc]
module.compute.google_compute_health_check.http: Refreshing state... [id=projects/<gcp-project-name>/global/healthChecks/dev--http-health-check-us-west2]
module.load_balancer.google_compute_health_check.http: Refreshing state... [id=projects/<gcp-project-name>/global/healthChecks/dev--http-health-check]
module.profiles.google_service_account.cloud_function[0]: Refreshing state... [id=projects/<gcp-project-name>/serviceAccounts/dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com]
module.cloud_function[0].google_storage_bucket.function_bucket: Refreshing state... [id=dev--cloud-function-bucket]
module.cloud_function[0].google_storage_bucket_object.function_archive[0]: Refreshing state... [id=dev--cloud-function-bucket-dev--stressload-webservers.zip]
module.networking.google_compute_router.nat_router: Refreshing state... [id=projects/<gcp-project-name>/regions/us-west2/routers/dev--webapp-router]
module.networking.google_compute_subnetwork.subnet: Refreshing state... [id=projects/<gcp-project-name>/regions/us-west2/subnetworks/dev--webapp-subnet]
module.networking.google_compute_global_address.cloudsql_psa_range: Refreshing state... [id=projects/<gcp-project-name>/global/addresses/dev--cloudsql-psa-range]
module.firewall.google_compute_firewall.allow_http_https: Refreshing state... [id=projects/<gcp-project-name>/global/firewalls/dev--allow-http-https]
module.compute.data.google_compute_zones.available: Read complete after 1s [id=projects/<gcp-project-name>/regions/us-west2]
module.firewall.google_compute_firewall.allow_ssh_iap: Refreshing state... [id=projects/<gcp-project-name>/global/firewalls/dev--allow-ssh-iap]
module.firewall.google_compute_firewall.allow_ssh: Refreshing state... [id=projects/<gcp-project-name>/global/firewalls/dev--allow-ssh-restricted]
module.networking.google_compute_router_nat.nat_config: Refreshing state... [id=<gcp-project-name>/us-west2/dev--webapp-router/dev--webapp-nat-config]
module.compute.google_compute_instance_template.web_server: Refreshing state... [id=projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250407174500889300000001]
module.profiles.google_project_iam_member.logging_viewer: Refreshing state... [id=<gcp-project-name>/roles/logging.viewer/serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.compute_viewer: Refreshing state... [id=<gcp-project-name>/roles/compute.viewer/serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_logging_viewer[0]: Refreshing state... [id=<gcp-project-name>/roles/logging.viewer/serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.monitoring_viewer: Refreshing state... [id=<gcp-project-name>/roles/monitoring.viewer/serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_compute_viewer[0]: Refreshing state... [id=<gcp-project-name>/roles/compute.viewer/serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0]: Refreshing state... [id=<gcp-project-name>/roles/monitoring.viewer/serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com]
module.compute.google_compute_region_instance_group_manager.web_servers: Refreshing state... [id=projects/<gcp-project-name>/regions/us-west2/instanceGroupManagers/dev--web-servers-group]
module.compute.google_compute_region_autoscaler.web_autoscaler: Refreshing state... [id=projects/<gcp-project-name>/regions/us-west2/autoscalers/dev--web-autoscaling]
module.load_balancer.google_compute_backend_service.web_backend: Refreshing state... [id=projects/<gcp-project-name>/global/backendServices/dev--web-backend-service]
module.load_balancer.google_compute_url_map.default: Refreshing state... [id=projects/<gcp-project-name>/global/urlMaps/dev--web-url-map]
module.load_balancer.google_compute_target_http_proxy.default: Refreshing state... [id=projects/<gcp-project-name>/global/targetHttpProxies/dev--web-http-proxy]
module.load_balancer.google_compute_global_forwarding_rule.http: Refreshing state... [id=projects/<gcp-project-name>/global/forwardingRules/dev--http-forwarding-rule]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Refreshing state... [id=projects%2F<gcp-project-name>%2Fglobal%2Fnetworks%2Fdev--webapp-vpc:servicenetworking.googleapis.com]
```

```terraform
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
      - project                     = "<gcp-project-name>" -> null
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
          - effective_time             = "2025-04-07T17:44:27.600Z" -> null
          - retention_duration_seconds = 604800 -> null
        }
    }

  # module.cloud_function[0].google_storage_bucket_object.function_archive[0] will be destroyed
  - resource "google_storage_bucket_object" "function_archive" {
      - bucket              = "dev--cloud-function-bucket" -> null
      - content_type        = "application/zip" -> null
      - crc32c              = "6UvsxA==" -> null
      - detect_md5hash      = "ST/PFx/7jNeUV7oAaYScAg==" -> null
      - event_based_hold    = false -> null
      - generation          = 1744048028688835 -> null
      - id                  = "dev--cloud-function-bucket-dev--stressload-webservers.zip" -> null
      - md5hash             = "ST/PFx/7jNeUV7oAaYScAg==" -> null
      - media_link          = "https://storage.googleapis.com/download/storage/v1/b/dev--cloud-function-bucket/o/dev--stressload-webservers.zip?generation=1744048028688835&alt=media" -> null
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
      - creation_timestamp  = "2025-04-07T10:44:27.455-07:00" -> null
      - healthy_threshold   = 2 -> null
      - id                  = "projects/<gcp-project-name>/global/healthChecks/dev--http-health-check-us-west2" -> null
      - name                = "dev--http-health-check-us-west2" -> null
      - project             = "<gcp-project-name>" -> null
      - self_link           = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/healthChecks/dev--http-health-check-us-west2" -> null
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
      - creation_timestamp         = "2025-04-07T10:45:01.518-07:00" -> null
      - effective_labels           = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                         = "projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250407174500889300000001" -> null
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
        } -> null
      - metadata_fingerprint       = "wkibT9ht_hI=" -> null
      - name                       = "dev--web-server-template--20250407174500889300000001" -> null
      - name_prefix                = "dev--web-server-template--" -> null
      - project                    = "<gcp-project-name>" -> null
      - region                     = "us-west2" -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250407174500889300000001" -> null
      - self_link_unique           = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250407174500889300000001?uniqueId=7042322625545744882" -> null
      - tags                       = [
          - "dev--http-server",
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
          - network                     = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
          - queue_count                 = 0 -> null
          - subnetwork                  = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/subnetworks/dev--webapp-subnet" -> null
          - subnetwork_project          = "<gcp-project-name>" -> null
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
      - creation_timestamp = "2025-04-07T10:45:23.535-07:00" -> null
      - id                 = "projects/<gcp-project-name>/regions/us-west2/autoscalers/dev--web-autoscaling" -> null
      - name               = "dev--web-autoscaling" -> null
      - project            = "<gcp-project-name>" -> null
      - region             = "us-west2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/autoscalers/dev--web-autoscaling" -> null
      - target             = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/instanceGroupManagers/dev--web-servers-group" -> null
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
      - creation_timestamp               = "2025-04-07T10:45:02.774-07:00" -> null
      - distribution_policy_target_shape = "EVEN" -> null
      - distribution_policy_zones        = [
          - "us-west2-a",
          - "us-west2-b",
          - "us-west2-c",
        ] -> null
      - fingerprint                      = "MFGc1_VkRhY=" -> null
      - id                               = "projects/<gcp-project-name>/regions/us-west2/instanceGroupManagers/dev--web-servers-group" -> null
      - instance_group                   = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/instanceGroups/dev--web-servers-group" -> null
      - instance_group_manager_id        = 7564082884820709873 -> null
      - list_managed_instances_results   = "PAGELESS" -> null
      - name                             = "dev--web-servers-group" -> null
      - project                          = "<gcp-project-name>" -> null
      - region                           = "us-west2" -> null
      - self_link                        = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/instanceGroupManagers/dev--web-servers-group" -> null
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
          - max_unavailable_fixed          = 0 -> null
          - max_unavailable_percent        = 0 -> null
          - minimal_action                 = "REPLACE" -> null
          - replacement_method             = "SUBSTITUTE" -> null
          - type                           = "OPPORTUNISTIC" -> null
            # (1 unchanged attribute hidden)
        }

      - version {
          - instance_template = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250407174500889300000001" -> null
            name              = null
        }
    }

  # module.firewall.google_compute_firewall.allow_http_https will be destroyed
  - resource "google_compute_firewall" "allow_http_https" {
      - creation_timestamp      = "2025-04-07T10:44:49.339-07:00" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/<gcp-project-name>/global/firewalls/dev--allow-http-https" -> null
      - name                    = "dev--allow-http-https" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
      - priority                = 1000 -> null
      - project                 = "<gcp-project-name>" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/firewalls/dev--allow-http-https" -> null
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
      - creation_timestamp      = "2025-04-07T10:44:49.371-07:00" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/<gcp-project-name>/global/firewalls/dev--allow-ssh-restricted" -> null
      - name                    = "dev--allow-ssh-restricted" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
      - priority                = 1000 -> null
      - project                 = "<gcp-project-name>" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/firewalls/dev--allow-ssh-restricted" -> null
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
      - creation_timestamp      = "2025-04-07T10:44:49.154-07:00" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/<gcp-project-name>/global/firewalls/dev--allow-ssh-iap" -> null
      - name                    = "dev--allow-ssh-iap" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
      - priority                = 1000 -> null
      - project                 = "<gcp-project-name>" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/firewalls/dev--allow-ssh-iap" -> null
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
      - creation_timestamp              = "2025-04-07T10:45:24.748-07:00" -> null
      - custom_request_headers          = [] -> null
      - custom_response_headers         = [] -> null
      - enable_cdn                      = false -> null
      - fingerprint                     = "o-PdFhRsApc=" -> null
      - generated_id                    = 458669091181933019 -> null
      - health_checks                   = [
          - "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/healthChecks/dev--http-health-check",
        ] -> null
      - id                              = "projects/<gcp-project-name>/global/backendServices/dev--web-backend-service" -> null
      - load_balancing_scheme           = "EXTERNAL" -> null
      - name                            = "dev--web-backend-service" -> null
      - port_name                       = "http" -> null
      - project                         = "<gcp-project-name>" -> null
      - protocol                        = "HTTP" -> null
      - self_link                       = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/backendServices/dev--web-backend-service" -> null
      - session_affinity                = "NONE" -> null
      - timeout_sec                     = 30 -> null
        # (7 unchanged attributes hidden)

      - backend {
          - balancing_mode               = "UTILIZATION" -> null
          - capacity_scaler              = 1 -> null
          - group                        = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/instanceGroups/dev--web-servers-group" -> null
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
      - forwarding_rule_id    = 338371970663559578 -> null
      - id                    = "projects/<gcp-project-name>/global/forwardingRules/dev--http-forwarding-rule" -> null
      - ip_address            = "34.49.100.242" -> null
      - ip_protocol           = "TCP" -> null
      - label_fingerprint     = "42WmSpB8rSM=" -> null
      - labels                = {} -> null
      - load_balancing_scheme = "EXTERNAL" -> null
      - name                  = "dev--http-forwarding-rule" -> null
      - network_tier          = "PREMIUM" -> null
      - port_range            = "80-80" -> null
      - project               = "<gcp-project-name>" -> null
      - self_link             = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/forwardingRules/dev--http-forwarding-rule" -> null
      - source_ip_ranges      = [] -> null
      - target                = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/targetHttpProxies/dev--web-http-proxy" -> null
      - terraform_labels      = {} -> null
        # (7 unchanged attributes hidden)
    }

  # module.load_balancer.google_compute_health_check.http will be destroyed
  - resource "google_compute_health_check" "http" {
      - check_interval_sec  = 5 -> null
      - creation_timestamp  = "2025-04-07T10:44:27.197-07:00" -> null
      - healthy_threshold   = 2 -> null
      - id                  = "projects/<gcp-project-name>/global/healthChecks/dev--http-health-check" -> null
      - name                = "dev--http-health-check" -> null
      - project             = "<gcp-project-name>" -> null
      - self_link           = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/healthChecks/dev--http-health-check" -> null
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
      - creation_timestamp          = "2025-04-07T10:46:18.373-07:00" -> null
      - http_keep_alive_timeout_sec = 0 -> null
      - id                          = "projects/<gcp-project-name>/global/targetHttpProxies/dev--web-http-proxy" -> null
      - name                        = "dev--web-http-proxy" -> null
      - project                     = "<gcp-project-name>" -> null
      - proxy_bind                  = false -> null
      - proxy_id                    = 7348942445341159813 -> null
      - self_link                   = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/targetHttpProxies/dev--web-http-proxy" -> null
      - url_map                     = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/urlMaps/dev--web-url-map" -> null
        # (1 unchanged attribute hidden)
    }

  # module.load_balancer.google_compute_url_map.default will be destroyed
  - resource "google_compute_url_map" "default" {
      - creation_timestamp = "2025-04-07T10:46:07.321-07:00" -> null
      - default_service    = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/backendServices/dev--web-backend-service" -> null
      - fingerprint        = "qA-QWRvmFEw=" -> null
      - id                 = "projects/<gcp-project-name>/global/urlMaps/dev--web-url-map" -> null
      - map_id             = 723124379513893296 -> null
      - name               = "dev--web-url-map" -> null
      - project            = "<gcp-project-name>" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/urlMaps/dev--web-url-map" -> null
        # (1 unchanged attribute hidden)
    }

  # module.networking.google_compute_global_address.cloudsql_psa_range will be destroyed
  - resource "google_compute_global_address" "cloudsql_psa_range" {
      - address            = "10.197.0.0" -> null
      - address_type       = "INTERNAL" -> null
      - creation_timestamp = "2025-04-07T10:44:49.194-07:00" -> null
      - effective_labels   = {
          - "dev--networking"            = "true"
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                 = "projects/<gcp-project-name>/global/addresses/dev--cloudsql-psa-range" -> null
      - label_fingerprint  = "yWa6jcLWH-0=" -> null
      - labels             = {
          - "dev--networking" = "true"
        } -> null
      - name               = "dev--cloudsql-psa-range" -> null
      - network            = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
      - prefix_length      = 16 -> null
      - project            = "<gcp-project-name>" -> null
      - purpose            = "VPC_PEERING" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/addresses/dev--cloudsql-psa-range" -> null
      - terraform_labels   = {
          - "dev--networking"            = "true"
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
      - id                                        = "projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
      - mtu                                       = 0 -> null
      - name                                      = "dev--webapp-vpc" -> null
      - network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL" -> null
      - network_id                                = "5093402552659718164" -> null
      - numeric_id                                = "5093402552659718164" -> null
      - project                                   = "<gcp-project-name>" -> null
      - routing_mode                              = "REGIONAL" -> null
      - self_link                                 = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
        # (5 unchanged attributes hidden)
    }

  # module.networking.google_compute_router.nat_router will be destroyed
  - resource "google_compute_router" "nat_router" {
      - creation_timestamp            = "2025-04-07T10:44:49.377-07:00" -> null
      - encrypted_interconnect_router = false -> null
      - id                            = "projects/<gcp-project-name>/regions/us-west2/routers/dev--webapp-router" -> null
      - name                          = "dev--webapp-router" -> null
      - network                       = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
      - project                       = "<gcp-project-name>" -> null
      - region                        = "us-west2" -> null
      - self_link                     = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/routers/dev--webapp-router" -> null
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
      - id                                  = "<gcp-project-name>/us-west2/dev--webapp-router/dev--webapp-nat-config" -> null
      - max_ports_per_vm                    = 0 -> null
      - min_ports_per_vm                    = 0 -> null
      - name                                = "dev--webapp-nat-config" -> null
      - nat_ip_allocate_option              = "AUTO_ONLY" -> null
      - nat_ips                             = [] -> null
      - project                             = "<gcp-project-name>" -> null
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
      - creation_timestamp         = "2025-04-07T10:44:50.025-07:00" -> null
      - enable_flow_logs           = false -> null
      - gateway_address            = "10.100.0.1" -> null
      - id                         = "projects/<gcp-project-name>/regions/us-west2/subnetworks/dev--webapp-subnet" -> null
      - ip_cidr_range              = "10.100.0.0/24" -> null
      - name                       = "dev--webapp-subnet" -> null
      - network                    = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
      - private_ip_google_access   = true -> null
      - private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS" -> null
      - project                    = "<gcp-project-name>" -> null
      - purpose                    = "PRIVATE" -> null
      - region                     = "us-west2" -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/subnetworks/dev--webapp-subnet" -> null
      - stack_type                 = "IPV4_ONLY" -> null
      - subnetwork_id              = 6681906553661534717 -> null
        # (9 unchanged attributes hidden)
    }

  # module.networking.google_project_service.servicenetworking will be destroyed
  - resource "google_project_service" "servicenetworking" {
      - disable_on_destroy = true -> null
      - id                 = "<gcp-project-name>/servicenetworking.googleapis.com" -> null
      - project            = "<gcp-project-name>" -> null
      - service            = "servicenetworking.googleapis.com" -> null
    }

  # module.networking.google_service_networking_connection.cloudsql_psa_connection will be destroyed
  - resource "google_service_networking_connection" "cloudsql_psa_connection" {
      - id                      = "projects%2F<gcp-project-name>%2Fglobal%2Fnetworks%2Fdev--webapp-vpc:servicenetworking.googleapis.com" -> null
      - network                 = "projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
      - peering                 = "servicenetworking-googleapis-com" -> null
      - reserved_peering_ranges = [
          - "dev--cloudsql-psa-range",
        ] -> null
      - service                 = "servicenetworking.googleapis.com" -> null
    }

  # module.profiles.google_project_iam_member.cli_admin_logging_viewer will be destroyed
  - resource "google_project_iam_member" "cli_admin_logging_viewer" {
      - etag    = "BwYyM8p9RNE=" -> null
      - id      = "<gcp-project-name>/roles/logging.viewer/serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - project = "<gcp-project-name>" -> null
      - role    = "roles/logging.viewer" -> null
    }

  # module.profiles.google_project_iam_member.cli_admin_storage_admin will be destroyed
  - resource "google_project_iam_member" "cli_admin_storage_admin" {
      - etag    = "BwYyM8p9RNE=" -> null
      - id      = "<gcp-project-name>/roles/storage.admin/serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - project = "<gcp-project-name>" -> null
      - role    = "roles/storage.admin" -> null
    }

  # module.profiles.google_project_iam_member.cloud_function_compute_viewer[0] will be destroyed
  - resource "google_project_iam_member" "cloud_function_compute_viewer" {
      - etag    = "BwYyM8p9RNE=" -> null
      - id      = "<gcp-project-name>/roles/compute.viewer/serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - project = "<gcp-project-name>" -> null
      - role    = "roles/compute.viewer" -> null
    }

  # module.profiles.google_project_iam_member.cloud_function_logging_viewer[0] will be destroyed
  - resource "google_project_iam_member" "cloud_function_logging_viewer" {
      - etag    = "BwYyM8p9RNE=" -> null
      - id      = "<gcp-project-name>/roles/logging.viewer/serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - project = "<gcp-project-name>" -> null
      - role    = "roles/logging.viewer" -> null
    }

  # module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0] will be destroyed
  - resource "google_project_iam_member" "cloud_function_monitoring_viewer" {
      - etag    = "BwYyM8p9RNE=" -> null
      - id      = "<gcp-project-name>/roles/monitoring.viewer/serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - project = "<gcp-project-name>" -> null
      - role    = "roles/monitoring.viewer" -> null
    }

  # module.profiles.google_project_iam_member.compute_viewer will be destroyed
  - resource "google_project_iam_member" "compute_viewer" {
      - etag    = "BwYyM8p9RNE=" -> null
      - id      = "<gcp-project-name>/roles/compute.viewer/serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - project = "<gcp-project-name>" -> null
      - role    = "roles/compute.viewer" -> null
    }

  # module.profiles.google_project_iam_member.logging_viewer will be destroyed
  - resource "google_project_iam_member" "logging_viewer" {
      - etag    = "BwYyM8p9RNE=" -> null
      - id      = "<gcp-project-name>/roles/logging.viewer/serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - project = "<gcp-project-name>" -> null
      - role    = "roles/logging.viewer" -> null
    }

  # module.profiles.google_project_iam_member.monitoring_viewer will be destroyed
  - resource "google_project_iam_member" "monitoring_viewer" {
      - etag    = "BwYyM8p9RNE=" -> null
      - id      = "<gcp-project-name>/roles/monitoring.viewer/serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - project = "<gcp-project-name>" -> null
      - role    = "roles/monitoring.viewer" -> null
    }

  # module.profiles.google_service_account.cloud_function[0] will be destroyed
  - resource "google_service_account" "cloud_function" {
      - account_id   = "dev--ro--cloud-function" -> null
      - disabled     = false -> null
      - display_name = "Cloud Function SA (Stress Test)" -> null
      - email        = "dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - id           = "projects/<gcp-project-name>/serviceAccounts/dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - member       = "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - name         = "projects/<gcp-project-name>/serviceAccounts/dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - project      = "<gcp-project-name>" -> null
      - unique_id    = "101824342671138803473" -> null
        # (1 unchanged attribute hidden)
    }

  # module.profiles.google_service_account.read_only will be destroyed
  - resource "google_service_account" "read_only" {
      - account_id   = "dev--ro--service-account" -> null
      - disabled     = false -> null
      - display_name = "Read-Only Service Account for dev" -> null
      - email        = "dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - id           = "projects/<gcp-project-name>/serviceAccounts/dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - member       = "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - name         = "projects/<gcp-project-name>/serviceAccounts/dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
      - project      = "<gcp-project-name>" -> null
      - unique_id    = "109975425921166456413" -> null
        # (1 unchanged attribute hidden)
    }

Plan: 0 to add, 0 to change, 31 to destroy.

Changes to Outputs:
  - cloud_function_bucket                     = "dev--cloud-function-bucket" -> null
  - cloud_function_service_account_email      = "dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
  - cloud_function_service_account_unique_id  = "101824342671138803473" -> null
  - cloud_function_tags                       = [] -> null
  - cloud_function_upload_target              = "module.cloud_function[0].google_storage_bucket_object.function_archive" -> null
  - cloudsql_psa_range_name                   = "dev--cloudsql-psa-range" -> null
  - compute_instance_tags                     = [
      - "ssh-access",
      - "dev--http-server",
    ] -> null
  - compute_instance_template                 = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250407174500889300000001" -> null
  - compute_instance_type                     = "e2-micro" -> null
  - compute_web_autoscaler_name               = "dev--web-autoscaling" -> null
  - compute_web_server_ip                     = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/instanceGroups/dev--web-servers-group" -> null
  - compute_web_servers_group                 = "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/instanceGroups/dev--web-servers-group" -> null
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
  - firewall_allow_ssh_iap_tags               = [
      - "ssh-access",
    ] -> null
  - firewall_allow_ssh_tags                   = [
      - "ssh-access",
    ] -> null
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
      - project_id  = "<gcp-project-name>"
      - provider    = "gcp"
      - regions     = {
          - central = "us-central2"
          - east    = "us-east2"
          - west    = "us-west2"
        }
      - services    = [
          - "cloud_function",
          - "compute_resources",
          - "firewall_rules",
          - "health_check",
          - "http_forwarding",
          - "load_balancer",
          - "networking",
          - "web_autoscaling",
          - "web_backend",
        ]
      - types       = {
          - medium   = "e2-medium"
          - micro    = "e2-micro"
          - standard = "n1-standard-1"
        }
    } -> null
  - http_forwarding_rule_name                 = "dev--http-forwarding-rule" -> null
  - http_health_check_name                    = "dev--http-health-check" -> null
  - load_balancer_ip                          = "34.49.100.242" -> null
  - load_balancer_tags                        = [
      - "dev--load-balancer",
    ] -> null
  - nat_name                                  = "dev--webapp-nat-config" -> null
  - networking_tags                           = [
      - "dev--networking",
    ] -> null
  - profiles_tags                             = [
      - "dev--service-accounts",
    ] -> null
  - project_id                                = "<gcp-project-name>" -> null
  - readonly_service_account_email            = "dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com" -> null
  - readonly_service_account_id               = "109975425921166456413" -> null
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
  - stressload_function_service_account_email = "dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com" -> null
  - stressload_key                            = "low" -> null
  - stressload_log_level                      = "info" -> null
  - subnet_id                                 = "projects/<gcp-project-name>/regions/us-west2/subnetworks/dev--webapp-subnet" -> null
  - vpc_network_id                            = "projects/<gcp-project-name>/global/networks/dev--webapp-vpc" -> null
  - web_backend_service_name                  = "dev--web-backend-service" -> null
  - workspace                                 = "dev" -> null
```

```terraform
Do you really want to destroy all resources in workspace "dev"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

```terraform
module.profiles.google_project_iam_member.monitoring_viewer: Destroying... [id=<gcp-project-name>/roles/monitoring.viewer/serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_compute_viewer[0]: Destroying... [id=<gcp-project-name>/roles/compute.viewer/serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.compute_viewer: Destroying... [id=<gcp-project-name>/roles/compute.viewer/serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Destroying... [id=projects%2F<gcp-project-name>%2Fglobal%2Fnetworks%2Fdev--webapp-vpc:servicenetworking.googleapis.com]
module.compute.google_compute_region_autoscaler.web_autoscaler: Destroying... [id=projects/<gcp-project-name>/regions/us-west2/autoscalers/dev--web-autoscaling]
module.cloud_function[0].google_storage_bucket_object.function_archive[0]: Destroying... [id=dev--cloud-function-bucket-dev--stressload-webservers.zip]
module.firewall.google_compute_firewall.allow_http_https: Destroying... [id=projects/<gcp-project-name>/global/firewalls/dev--allow-http-https]
module.load_balancer.google_compute_global_forwarding_rule.http: Destroying... [id=projects/<gcp-project-name>/global/forwardingRules/dev--http-forwarding-rule]
module.compute.google_compute_health_check.http: Destroying... [id=projects/<gcp-project-name>/global/healthChecks/dev--http-health-check-us-west2]
module.firewall.google_compute_firewall.allow_ssh_iap: Destroying... [id=projects/<gcp-project-name>/global/firewalls/dev--allow-ssh-iap]
module.cloud_function[0].google_storage_bucket_object.function_archive[0]: Destruction complete after 0s
module.firewall.google_compute_firewall.allow_ssh: Destroying... [id=projects/<gcp-project-name>/global/firewalls/dev--allow-ssh-restricted]
module.profiles.google_project_iam_member.monitoring_viewer: Destruction complete after 8s
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0]: Destroying... [id=<gcp-project-name>/roles/monitoring.viewer/serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.compute_viewer: Destruction complete after 8s
module.profiles.google_project_iam_member.cli_admin_logging_viewer: Destroying... [id=<gcp-project-name>/roles/logging.viewer/serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.cloud_function_compute_viewer[0]: Destruction complete after 8s
module.networking.google_compute_router_nat.nat_config: Destroying... [id=<gcp-project-name>/us-west2/dev--webapp-router/dev--webapp-nat-config]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still destroying... [id=projects%2F<gcp-project-name>%2Fglob...p-vpc:servicenetworking.googleapis.com, 10s elapsed]
module.compute.google_compute_region_autoscaler.web_autoscaler: Still destroying... [id=projects/<gcp-project-name>/regions/us-west2/autoscalers/dev--web-autoscaling, 10s elapsed]
module.firewall.google_compute_firewall.allow_http_https: Still destroying... [id=projects/<gcp-project-name>/global/firewalls/dev--allow-http-https, 10s elapsed]
module.load_balancer.google_compute_global_forwarding_rule.http: Still destroying... [id=projects/<gcp-project-name>/global/forwardingRules/dev--http-forwarding-rule, 10s elapsed]
module.compute.google_compute_health_check.http: Still destroying... [id=projects/<gcp-project-name>/global/h...Checks/dev--http-health-check-us-west2, 10s elapsed]
module.firewall.google_compute_firewall.allow_ssh_iap: Still destroying... [id=projects/<gcp-project-name>/global/firewalls/dev--allow-ssh-iap, 10s elapsed]
module.firewall.google_compute_firewall.allow_ssh: Still destroying... [id=projects/<gcp-project-name>/global/firewalls/dev--allow-ssh-restricted, 10s elapsed]
module.compute.google_compute_region_autoscaler.web_autoscaler: Destruction complete after 11s
module.profiles.google_project_iam_member.cloud_function_logging_viewer[0]: Destroying... [id=<gcp-project-name>/roles/logging.viewer/serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com]
module.firewall.google_compute_firewall.allow_ssh: Destruction complete after 11s
module.profiles.google_project_iam_member.logging_viewer: Destroying... [id=<gcp-project-name>/roles/logging.viewer/serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com]
module.compute.google_compute_health_check.http: Destruction complete after 11s
module.profiles.google_project_iam_member.cli_admin_storage_admin: Destroying... [id=<gcp-project-name>/roles/storage.admin/serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com]
module.firewall.google_compute_firewall.allow_ssh_iap: Destruction complete after 11s
module.cloud_function[0].google_storage_bucket.function_bucket: Destroying... [id=dev--cloud-function-bucket]
module.firewall.google_compute_firewall.allow_http_https: Destruction complete after 11s
module.cloud_function[0].google_storage_bucket.function_bucket: Destruction complete after 1s
module.profiles.google_project_iam_member.cli_admin_logging_viewer: Destruction complete after 7s
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0]: Still destroying... [id=<gcp-project-name>/roles/monitoring....lead-454601-q1.iam.gserviceaccount.com, 10s elapsed]
module.networking.google_compute_router_nat.nat_config: Still destroying... [id=<gcp-project-name>/us-west2/dev--webapp-router/dev--webapp-nat-config, 10s elapsed]
module.networking.google_compute_router_nat.nat_config: Destruction complete after 11s
module.networking.google_compute_router.nat_router: Destroying... [id=projects/<gcp-project-name>/regions/us-west2/routers/dev--webapp-router]
module.profiles.google_project_iam_member.cloud_function_monitoring_viewer[0]: Destruction complete after 12s
module.profiles.google_project_iam_member.cli_admin_storage_admin: Destruction complete after 9s
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still destroying... [id=projects%2F<gcp-project-name>%2Fglob...p-vpc:servicenetworking.googleapis.com, 20s elapsed]
module.load_balancer.google_compute_global_forwarding_rule.http: Still destroying... [id=projects/<gcp-project-name>/global/forwardingRules/dev--http-forwarding-rule, 20s elapsed]
module.profiles.google_project_iam_member.cloud_function_logging_viewer[0]: Destruction complete after 9s
module.profiles.google_service_account.cloud_function[0]: Destroying... [id=projects/<gcp-project-name>/serviceAccounts/dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_project_iam_member.logging_viewer: Destruction complete after 9s
module.profiles.google_service_account.cloud_function[0]: Destruction complete after 1s
module.profiles.google_service_account.read_only: Destroying... [id=projects/<gcp-project-name>/serviceAccounts/dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com]
module.profiles.google_service_account.read_only: Destruction complete after 0s
module.load_balancer.google_compute_global_forwarding_rule.http: Destruction complete after 21s
module.load_balancer.google_compute_target_http_proxy.default: Destroying... [id=projects/<gcp-project-name>/global/targetHttpProxies/dev--web-http-proxy]
module.networking.google_compute_router.nat_router: Still destroying... [id=projects/<gcp-project-name>/regions/us-west2/routers/dev--webapp-router, 10s elapsed]
module.networking.google_compute_router.nat_router: Destruction complete after 10s
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still destroying... [id=projects%2F<gcp-project-name>%2Fglob...p-vpc:servicenetworking.googleapis.com, 30s elapsed]
module.load_balancer.google_compute_target_http_proxy.default: Still destroying... [id=projects/<gcp-project-name>/global/targetHttpProxies/dev--web-http-proxy, 10s elapsed]
module.load_balancer.google_compute_target_http_proxy.default: Destruction complete after 11s
module.load_balancer.google_compute_url_map.default: Destroying... [id=projects/<gcp-project-name>/global/urlMaps/dev--web-url-map]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Still destroying... [id=projects%2F<gcp-project-name>%2Fglob...p-vpc:servicenetworking.googleapis.com, 40s elapsed]
module.networking.google_service_networking_connection.cloudsql_psa_connection: Destruction complete after 42s
module.load_balancer.google_compute_url_map.default: Still destroying... [id=projects/<gcp-project-name>/global/urlMaps/dev--web-url-map, 10s elapsed]
module.networking.google_project_service.servicenetworking: Destroying... [id=<gcp-project-name>/servicenetworking.googleapis.com]
module.networking.google_compute_global_address.cloudsql_psa_range: Destroying... [id=projects/<gcp-project-name>/global/addresses/dev--cloudsql-psa-range]
module.load_balancer.google_compute_url_map.default: Destruction complete after 11s
module.load_balancer.google_compute_backend_service.web_backend: Destroying... [id=projects/<gcp-project-name>/global/backendServices/dev--web-backend-service]
module.networking.google_project_service.servicenetworking: Still destroying... [id=<gcp-project-name>/servicenetworking.googleapis.com, 10s elapsed]
module.networking.google_compute_global_address.cloudsql_psa_range: Still destroying... [id=projects/<gcp-project-name>/global/addresses/dev--cloudsql-psa-range, 10s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still destroying... [id=projects/<gcp-project-name>/global/backendServices/dev--web-backend-service, 10s elapsed]
module.networking.google_project_service.servicenetworking: Destruction complete after 11s
module.networking.google_compute_global_address.cloudsql_psa_range: Destruction complete after 11s
module.load_balancer.google_compute_backend_service.web_backend: Still destroying... [id=projects/<gcp-project-name>/global/backendServices/dev--web-backend-service, 20s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still destroying... [id=projects/<gcp-project-name>/global/backendServices/dev--web-backend-service, 30s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Still destroying... [id=projects/<gcp-project-name>/global/backendServices/dev--web-backend-service, 40s elapsed]
module.load_balancer.google_compute_backend_service.web_backend: Destruction complete after 42s
module.load_balancer.google_compute_health_check.http: Destroying... [id=projects/<gcp-project-name>/global/healthChecks/dev--http-health-check]
module.compute.google_compute_region_instance_group_manager.web_servers: Destroying... [id=projects/<gcp-project-name>/regions/us-west2/instanceGroupManagers/dev--web-servers-group]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/<gcp-project-name>/regions/...ceGroupManagers/dev--web-servers-group, 10s elapsed]
module.load_balancer.google_compute_health_check.http: Still destroying... [id=projects/<gcp-project-name>/global/healthChecks/dev--http-health-check, 10s elapsed]
module.load_balancer.google_compute_health_check.http: Destruction complete after 11s
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/<gcp-project-name>/regions/...ceGroupManagers/dev--web-servers-group, 20s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/<gcp-project-name>/regions/...ceGroupManagers/dev--web-servers-group, 30s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/<gcp-project-name>/regions/...ceGroupManagers/dev--web-servers-group, 40s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/<gcp-project-name>/regions/...ceGroupManagers/dev--web-servers-group, 50s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/<gcp-project-name>/regions/...ceGroupManagers/dev--web-servers-group, 1m0s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/<gcp-project-name>/regions/...ceGroupManagers/dev--web-servers-group, 1m10s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Still destroying... [id=projects/<gcp-project-name>/regions/...ceGroupManagers/dev--web-servers-group, 1m20s elapsed]
module.compute.google_compute_region_instance_group_manager.web_servers: Destruction complete after 1m21s
module.compute.google_compute_instance_template.web_server: Destroying... [id=projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250407174500889300000001]
module.compute.google_compute_instance_template.web_server: Still destroying... [id=projects/<gcp-project-name>/global/i...r-template--20250407174500889300000001, 10s elapsed]
module.compute.google_compute_instance_template.web_server: Destruction complete after 10s
module.networking.google_compute_subnetwork.subnet: Destroying... [id=projects/<gcp-project-name>/regions/us-west2/subnetworks/dev--webapp-subnet]
module.networking.google_compute_subnetwork.subnet: Still destroying... [id=projects/<gcp-project-name>/regions/us-west2/subnetworks/dev--webapp-subnet, 10s elapsed]
module.networking.google_compute_subnetwork.subnet: Still destroying... [id=projects/<gcp-project-name>/regions/us-west2/subnetworks/dev--webapp-subnet, 20s elapsed]
module.networking.google_compute_subnetwork.subnet: Destruction complete after 21s
module.networking.google_compute_network.vpc_network: Destroying... [id=projects/<gcp-project-name>/global/networks/dev--webapp-vpc]
module.networking.google_compute_network.vpc_network: Still destroying... [id=projects/<gcp-project-name>/global/networks/dev--webapp-vpc, 10s elapsed]
module.networking.google_compute_network.vpc_network: Still destroying... [id=projects/<gcp-project-name>/global/networks/dev--webapp-vpc, 20s elapsed]
module.networking.google_compute_network.vpc_network: Destruction complete after 21s
```

```terraform
Destroy complete! Resources: 31 destroyed.
```
