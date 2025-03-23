# Script: `inspect-services.shell`

**Version:** `0.1.0`

**Purpose:**
This script retrieves and displays a set of GCP infrastructure resource states—primarily related to networking, compute, and load balancer components—within the current GCP project. It acts as a consolidated diagnostic and visibility tool for platform engineers to quickly audit deployed services and confirm the status of running resources.

## Location
`scripts/manage/inspect-services.shell`

## Execution Context
- Run interactively from a Unix shell with `gcloud` installed.
- User must be authenticated and authorized for all `compute` and `network` APIs.
- Can be used during troubleshooting, post-deployment validation, or CI/CD auditing.

## Functional Summary
The script sequentially invokes `gcloud` CLI commands to:

1. **List Forwarding Rules**
   - Displays global forwarding rules to verify the exposure of HTTP(S) load balancers.

2. **List Target Proxies and URL Maps**
   - Prints proxy configuration, which controls routing behavior and backend selection.

3. **List Backend Services and Health Checks**
   - Confirms backend registration, attached instance groups, and probe health status.

4. **List Compute Instance Groups**
   - Displays Managed Instance Groups and associated metadata.

5. **List Instance Templates**
   - Shows templates linked to instance groups, including source images and VM metadata.

6. **List Network and Subnet Details**
   - Displays VPC networks, subnet CIDRs, and routing relationships.

7. **List Firewall Rules**
   - Outputs all configured ingress/egress rules to verify exposure control.

8. **Backend Health Check Evaluation** *(Advanced)*
   - Evaluates health of backend instances using `gcloud compute backend-services get-health`.
   - Reports on individual VM health status and readiness to receive traffic.

9. **End-to-End Service Validation** *(Optional)*
   - Performs a `curl` request to the public IP address of the ALB to confirm HTTP responsiveness.
   - Helps validate external accessibility of web services.

## Technical Highlights
- **GCP Surface Coverage:** The script consolidates visibility across networking and compute layers.
- **Zone-Agnostic:** Most commands operate across all regions unless otherwise specified.
- **Formatted Output:** Results are presented in readable tabular or summary formats suitable for inspection.
- **Trace-Based Topology Analysis:** Enables full tracing from load balancer ingress to instance group egress.

## Dependencies
- `gcloud` CLI must be installed and authenticated
- Project must contain active infrastructure provisioned by Terraform or otherwise
- Sufficient IAM permissions to list compute, network, and load balancer resources
- Optional tools: `curl` and `jq` for enhanced validation and output formatting

## Example Usage
```bash
chmod +x scripts/manage/inspect-services.shell
./scripts/manage/inspect-services.shell
```

## Extension Opportunities
- Add filters by region or label to reduce noise in large deployments
- Output JSON to support automated log ingestion or dashboarding
- Add section headers or color-coded status summaries for better visual parsing
- Pipe results to file for offline inspection or compliance reports
- Parameterize script with CLI arguments to target specific forwarding rules or proxies

## Use Cases
- **Post-Deployment Validation:** Confirm that all infrastructure layers (network, proxy, compute) are wired correctly
- **CI/CD Gatekeeping:** Automate infrastructure checks before executing service-level tests
- **Debugging Traffic Failures:** Trace backend instance readiness and misconfiguration root causes
- **Operational Visibility:** Periodically audit deployed services across environments

## Summary
`inspect-services.shell` provides an all-in-one visibility tool to help GCP users audit critical infrastructure state—particularly around load balancing, network topology, compute templates, and firewall access. It enables structured inspection of ALB configurations by tracing traffic paths from the public forwarding rule through proxies, URL maps, and backend services to the VM instances, and optionally confirms public availability via direct HTTP tests.

This tool is especially useful in post-deployment validation, CI pipeline reviews, and platform-wide troubleshooting scenarios. It increases service confidence by consolidating visibility and promoting observability across cloud service components.

---

```console
$ gsutil ls gs://dev--cloud-function-bucket ;
gs://dev--cloud-function-bucket/dev--stressload-webservers.zip
```

```console
$ ./scripts/manage/package-functions.shell ;

Stress-Load Package: packages/stressload-webservers.zip
Stress-Load Config: scripts/stressload/webservers/config.json

Terraform outputs extracted to: outputs.json
-rw-r--r--@ 1 emvaldes  staff  16886 Apr  5 01:39 outputs.json

Extracting Cloud Function configurations (terraform state)...
Project ID: <gcp-project-name>

```

```json
Auto-Scaling Profile: basic
Auto-Scaling Config: {
  "min": 1,
  "max": 2,
  "threshold": 0.6,
  "cooldown": 60
}
```

```json
Stress-Load Level: low
Stressload Config: {
  "duration": 60,
  "threads": 250,
  "interval": 0.04,
  "requests": 10000
}
```

```console
Function Name:            webapp-stress-tester
Function Region:          us-west2
Function Bucket:          cloud-function-bucket
Function Service Account: dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com
```

```json
Created Config-File:  scripts/stressload/webservers/config.json
{
  "target_url": "http://34.8.19.233",
  "project_id": "<gcp-project-name>",
  "region": "us-west2",
  "mig_name": "dev--web-servers-group",
  "autoscaler_name": "dev--web-autoscaling",
  "log_level": "low",
  "stress_duration_seconds": 60,
  "stress_concurrency": 250,
  "request_sleep_interval": 0.04,
  "autoscaler_min_replicas": 1,
  "autoscaler_max_replicas": 2
}
```

```console
Including: scripts/stressload/webservers/main.py
Including: scripts/stressload/webservers/requirements.txt
Including: scripts/stressload/webservers/config.json

Packaging: [scripts/stressload/webservers] stressload-webservers.zip
  adding: config.json (deflated 42%)
  adding: main.py (deflated 65%)
  adding: requirements.txt (deflated 41%)

Created archive: packages/stressload-webservers.zip
-rw-r--r--  1 emvaldes  staff  2646 Apr  5 01:39 packages/stressload-webservers.zip

Archive:  packages/stressload-webservers.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
      373  04-05-2025 01:39   config.json
     4720  04-04-2025 13:06   main.py
      537  04-04-2025 13:06   requirements.txt
---------                     -------
     5630                     3 files
```

```console
Cloud-Function Bucket's Size/Count:
2646         gs://dev--cloud-function-bucket

Cloud-Function Bucket's Metadata:
gs://dev--cloud-function-bucket/ :

  Storage class:            STANDARD
  Location type:            region
  Location constraint:      US-WEST2
  Versioning enabled:       None
  Logging configuration:    None
  Website configuration:    None
  CORS configuration:       None
  Lifecycle configuration:  None
  Requester Pays enabled:   None
```

```json
  Labels:
    {
      "goog-terraform-provisioned": "true"
    }
```

```console
  Default KMS key:             None
  Time created:                Sat, 05 Apr 2025 07:47:15 GMT
  Time updated:                Sat, 05 Apr 2025 07:47:15 GMT
  Metageneration:              1
  Bucket Policy Only enabled:  False
  Public access prevention:    inherited
```

```json
  ACL:
    [
      {
        "entity": "project-owners-776293755095",
        "projectTeam": {
          "projectNumber": "776293755095",
          "team": "owners"
        },
        "role": "OWNER"
      },
      {
        "entity": "project-editors-776293755095",
        "projectTeam": {
          "projectNumber": "776293755095",
          "team": "editors"
        },
        "role": "OWNER"
      },
      {
        "entity": "project-viewers-776293755095",
        "projectTeam": {
          "projectNumber": "776293755095",
          "team": "viewers"
        },
        "role": "READER"
      }
    ]
```

```json
  Default ACL:
    [
      {
        "entity": "project-owners-776293755095",
        "projectTeam": {
          "projectNumber": "776293755095",
          "team": "owners"
        },
        "role": "OWNER"
      },
      {
        "entity": "project-editors-776293755095",
        "projectTeam": {
          "projectNumber": "776293755095",
          "team": "editors"
        },
        "role": "OWNER"
      },
      {
        "entity": "project-viewers-776293755095",
        "projectTeam": {
          "projectNumber": "776293755095",
          "team": "viewers"
        },
        "role": "READER"
      }
    ]
```

---

```console
$ ./scripts/manage/inspect-services.shell ;
Forwarding Rule Description: dev--http-forwarding-rule
```

```
$ gcloud compute forwarding-rules describe dev--http-forwarding-rule --global --format=json ;
```

```json
{
  "IPAddress": "34.49.100.242",
  "IPProtocol": "TCP",
  "creationTimestamp": "2025-04-07T10:46:30.023-07:00",
  "description": "",
  "fingerprint": "uFJneYVugTU=",
  "id": "338371970663559578",
  "kind": "compute#forwardingRule",
  "labelFingerprint": "42WmSpB8rSM=",
  "loadBalancingScheme": "EXTERNAL",
  "name": "dev--http-forwarding-rule",
  "networkTier": "PREMIUM",
  "portRange": "80-80",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/forwardingRules/dev--http-forwarding-rule",
  "target": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/targetHttpProxies/dev--web-http-proxy"
}

External IP:  34.8.19.233
Target Proxy: dev--web-http-proxy
```

---

```console
$ gcloud compute target-http-proxies describe dev--web-http-proxy --format=json ;
```

```json
{
  "creationTimestamp": "2025-04-07T10:46:18.373-07:00",
  "fingerprint": "v7iWTG4S3HE=",
  "id": "7348942445341159813",
  "kind": "compute#targetHttpProxy",
  "name": "dev--web-http-proxy",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/targetHttpProxies/dev--web-http-proxy",
  "urlMap": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/urlMaps/dev--web-url-map"
}

URL Map: dev--web-url-map
```

---

```console
$ gcloud compute url-maps describe dev--web-url-map --format=json ;
```

```json
{
  "creationTimestamp": "2025-04-07T10:46:07.321-07:00",
  "defaultService": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/backendServices/dev--web-backend-service",
  "fingerprint": "qA-QWRvmFEw=",
  "id": "723124379513893296",
  "kind": "compute#urlMap",
  "name": "dev--web-url-map",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/urlMaps/dev--web-url-map"
}

Backend Service: dev--web-backend-service
```

---

```console
$ gcloud compute backend-services describe dev--web-backend-service --global --format=json ;
```

```json
{
  "affinityCookieTtlSec": 0,
  "backends": [
    {
      "balancingMode": "UTILIZATION",
      "capacityScaler": 1.0,
      "group": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/instanceGroups/dev--web-servers-group"
    }
  ],
  "connectionDraining": {
    "drainingTimeoutSec": 300
  },
  "creationTimestamp": "2025-04-07T10:45:24.748-07:00",
  "description": "",
  "enableCDN": false,
  "fingerprint": "o-PdFhRsApc=",
  "healthChecks": [
    "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/healthChecks/dev--http-health-check"
  ],
  "id": "458669091181933019",
  "kind": "compute#backendService",
  "loadBalancingScheme": "EXTERNAL",
  "name": "dev--web-backend-service",
  "port": 80,
  "portName": "http",
  "protocol": "HTTP",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/backendServices/dev--web-backend-service",
  "sessionAffinity": "NONE",
  "timeoutSec": 30,
  "usedBy": [
    {
      "reference": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/urlMaps/dev--web-url-map"
    }
  ]
}

Group Instance:     dev--web-servers-group
Group Region:       us-west2
HTTP Health Check:  dev--http-health-check
```

---

```console
$ gcloud compute backend-services get-health dev--web-backend-service --global --format=json ;
```

```json
[
  {
    "backend": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/instanceGroups/dev--web-servers-group",
    "status": {
      "healthStatus": [
        {
          "healthState": "HEALTHY",
          "instance": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-c/instances/dev--web-server-03vb",
          "ipAddress": "10.100.0.2",
          "port": 80
        }
      ],
      "kind": "compute#backendServiceGroupHealth"
    }
  }
]

Health Status - State: HEALTHY
```

---

```console
$ gcloud compute health-checks describe dev--http-health-check --format=json --project=<gcp-project-name>
```

```json
{
  "checkIntervalSec": 5,
  "creationTimestamp": "2025-04-07T10:44:27.197-07:00",
  "healthyThreshold": 2,
  "httpHealthCheck": {
    "port": 80,
    "proxyHeader": "NONE",
    "requestPath": "/"
  },
  "id": "2934350113895198740",
  "kind": "compute#healthCheck",
  "name": "dev--http-health-check",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/healthChecks/dev--http-health-check",
  "timeoutSec": 5,
  "type": "HTTP",
  "unhealthyThreshold": 2
}

Check Interval: 5 seconds
Timeout:        5 seconds
Port:           null
```

---

```console
Web Server HTTP Response Check
curl --head --connect-timeout 10 http://34.8.19.233

Waiting for web-server (34.49.100.242) response ...........................

HTTP/1.1 200 OK
Date: Mon, 07 Apr 2025 17:49:57 GMT
Server: Apache/2.4.41 (Ubuntu)
Last-Modified: Mon, 07 Apr 2025 17:47:36 GMT
ETag: "3b-63233d4e815fe"
Accept-Ranges: bytes
Content-Length: 59
Content-Type: text/html
Via: 1.1 google
```

---

```console
$ curl -H "Authorization: Bearer ***" https://compute.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/autoscalers/dev--web-autoscaling ;
```

```json
{
  "kind": "compute#autoscaler",
  "id": "8786178896473731548",
  "creationTimestamp": "2025-04-07T10:45:23.535-07:00",
  "name": "dev--web-autoscaling",
  "target": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/instanceGroupManagers/dev--web-servers-group",
  "autoscalingPolicy": {
    "minNumReplicas": 1,
    "maxNumReplicas": 2,
    "coolDownPeriodSec": 60,
    "cpuUtilization": {
      "utilizationTarget": 0.6,
      "predictiveMethod": "NONE"
    },
    "mode": "ON"
  },
  "region": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/autoscalers/dev--web-autoscaling",
  "status": "ACTIVE",
  "recommendedSize": 2
}

Min Replicas: 1
Max Replicas: 2
Cooldown:     60
CPU Target:   0.6
```

---

```console
$ gcloud compute addresses describe dev--cloudsql-psa-range --global --project=<gcp-project-name> --format=json ;
```

```json
{
  "address": "10.197.0.0",
  "addressType": "INTERNAL",
  "creationTimestamp": "2025-04-07T10:44:49.194-07:00",
  "description": "",
  "id": "8358082721349218814",
  "kind": "compute#address",
  "labelFingerprint": "yWa6jcLWH-0=",
  "labels": {
    "dev--networking": "true",
    "goog-terraform-provisioned": "true"
  },
  "name": "dev--cloudsql-psa-range",
  "network": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc",
  "networkTier": "PREMIUM",
  "prefixLength": 16,
  "purpose": "VPC_PEERING",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/addresses/dev--cloudsql-psa-range",
  "status": "RESERVED"
}

Address Type: INTERNAL
Prefix Length: 16
Purpose: VPC_PEERING
Network: https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc
```

---

```console
$ gcloud services vpc-peerings list --network=dev--webapp-vpc --project=<gcp-project-name> --format=json ;
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

Completed the Application Load Balancer inspection.
```

```json
Instance: dev--web-server-03vb (us-west2-c)
{
  "cpuPlatform": "Intel Broadwell",
  "creationTimestamp": "2025-04-07T10:45:22.544-07:00",
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
          "type": "VIRTIO_SCSI_MULTIQUEUE"
        },
        {
          "type": "SEV_CAPABLE"
        },
        {
          "type": "SEV_SNP_CAPABLE"
        },
        {
          "type": "SEV_LIVE_MIGRATABLE"
        },
        {
          "type": "SEV_LIVE_MIGRATABLE_V2"
        },
        {
          "type": "IDPF"
        },
        {
          "type": "UEFI_COMPATIBLE"
        },
        {
          "type": "GVNIC"
        }
      ],
      "index": 0,
      "interface": "SCSI",
      "kind": "compute#attachedDisk",
      "licenses": [
        "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/licenses/ubuntu-2004-lts"
      ],
      "mode": "READ_WRITE",
      "shieldedInstanceInitialState": {
        "dbxs": [
          {
            "content": "2gcDBhMRFQ...MlNhWln344=",
            "fileType": "BIN"
          }
        ]
      },
      "source": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-c/disks/dev--web-server-03vb",
      "type": "PERSISTENT"
    }
  ],
  "fingerprint": "VSrGD9Emeb0=",
  "id": "636334850082189789",
  "kind": "compute#instance",
  "labelFingerprint": "vezUS-42LLM=",
  "labels": {
    "goog-terraform-provisioned": "true"
  },
  "lastStartTimestamp": "2025-04-07T10:45:30.971-07:00",
  "machineType": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-c/machineTypes/e2-micro",
  "metadata": {
    "fingerprint": "dkLaiID9Wr8=",
    "items": [
      {
        "key": "instance-template",
        "value": "projects/776293755095/global/instanceTemplates/dev--web-server-template--20250407174500889300000001"
      },
      {
        "key": "created-by",
        "value": "projects/776293755095/regions/us-west2/instanceGroupManagers/dev--web-servers-group"
      },
      {
        "key": "startup-script",
        "value": "#!/bin/bash\n\n# File: ./scripts/configure/apache-webserver.shell\n# Version: 0.1.0\n\n# Update package lists\nsudo apt update -y;\n\n# Install Apache web server\nsudo apt install -y apache2;\n\n# Start and enable Apache\nsudo systemctl start apache2;\nsudo systemctl enable apache2;\n\n# Create a simple HTML page to verify the instance is running\necho -e \"<h1>Server $(hostname) is running behind ALB</h1>\" \\\n   | sudo tee /var/www/html/index.html;\n\n# Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1078-gcp x86_64)\n\n#  * Documentation:  https://help.ubuntu.com\n#  * Management:     https://landscape.canonical.com\n#  * Support:        https://ubuntu.com/pro\n\n#  System information as of Mon Apr  7 15:39:01 UTC 2025\n\n#   System load:  0.0               Processes:             106\n#   Usage of /:   22.6% of 9.51GB   Users logged in:       0\n#   Memory usage: 24%               IPv4 address for ens4: 10.100.0.2\n#   Swap usage:   0%\n\n# Expanded Security Maintenance for Applications is not enabled.\n\n# 21 updates can be applied immediately.\n# 19 of these updates are standard security updates.\n# To see these additional updates run: apt list --upgradable\n\n# Enable ESM Apps to receive additional future security updates.\n# See https://ubuntu.com/esm or run: sudo pro status\n\n# The programs included with the Ubuntu system are free software;\n# the exact distribution terms for each program are described in the\n# individual files in /usr/share/doc/*/copyright.\n\n# Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by\n# applicable law.\n\n# devops_workflows@dev--web-server-840m:~$ curl --head localhost ;\n# HTTP/1.1 200 OK\n# Date: Mon, 07 Apr 2025 15:52:27 GMT\n# Server: Apache/2.4.41 (Ubuntu)\n# Last-Modified: Mon, 07 Apr 2025 15:31:19 GMT\n# ETag: \"3b-63231ed7cb253\"\n# Accept-Ranges: bytes\n# Content-Length: 59\n# Content-Type: text/html \n"
      }
    ],
    "kind": "compute#metadata"
  },
  "name": "dev--web-server-03vb",
  "networkInterfaces": [
    {
      "fingerprint": "lTRX_bZqO3s=",
      "kind": "compute#networkInterface",
      "name": "nic0",
      "network": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/networks/dev--webapp-vpc",
      "networkIP": "10.100.0.2",
      "stackType": "IPV4_ONLY",
      "subnetwork": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/subnetworks/dev--webapp-subnet"
    }
  ],
  "satisfiesPzi": true,
  "scheduling": {
    "automaticRestart": true,
    "onHostMaintenance": "MIGRATE",
    "preemptible": false,
    "provisioningModel": "STANDARD"
  },
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-c/instances/dev--web-server-03vb",
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
    "fingerprint": "NAyDSwpTNgY=",
    "items": [
      "dev--http-server",
      "ssh-access"
    ]
  },
  "zone": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-c"
}
```

---

```console
Unified IAM Role & Profile Inspection for Terraform-Managed Identities
Terraform-Managed IAM Identities with Roles and Profiles:
```

```json
[
  {
    "member": "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com",
    "profile": {
      "name": "projects/<gcp-project-name>/serviceAccounts/dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com",
      "email": "dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com",
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
    "member": "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com",
    "profile": {
      "name": "projects/<gcp-project-name>/serviceAccounts/dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com",
      "email": "dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com",
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

Exported:
  iam_terraform_identities_json (JSON)
  iam_scoped_member="dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com"
  iam_scoped_roles_json (JSON)
  iam_profile_json (JSON)
```

---

```console
IAM Custom Roles Inspection (Full)
No custom IAM roles found in project: <gcp-project-name>
```

---

```console
IAM Policy Bindings Inspection (Scoped to Terraform-Managed Roles)
Analyzing bindings for roles managed by Terraform...
```

```json
[
  {
    "role": "roles/compute.viewer",
    "managed": [
      "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com",
      "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com"
    ]
  },
  {
    "role": "roles/logging.viewer",
    "managed": [
      "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com",
      "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com",
      "serviceAccount:gcp-cli-admin@<gcp-project-name>.iam.gserviceaccount.com"
    ]
  },
  {
    "role": "roles/monitoring.viewer",
    "managed": [
      "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com",
      "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com"
    ]
  }
]
```

---

```console
IAM Activity Logs (Terraform-Managed Identities)
Querying GCP logs for the following IAM members:
dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com
dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com
```

---

```console
Autoscaler Activity Log Inspection
No autoscaler logs found matching: autoscalers/
```

---

```console
IAM Role Assignments Diff (Terraform vs. GCP)
```

```json
[
  {
    "member": "serviceAccount:dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com",
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
    "member": "serviceAccount:dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com",
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

---

```console
IAM Unbound Identities (Terraform-Managed Without GCP Role Bindings)

[]
```

---

```console
IAM Key Origin Inspection (Terraform-Managed Service Accounts)
All Keys (User & System Managed):
```

```json
[
  {
    "service_account": "dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com",
    "name": "projects/<gcp-project-name>/serviceAccounts/dev--ro--service-account@<gcp-project-name>.iam.gserviceaccount.com/keys/aa265c40804ac1fb55d895f03648639983a05665",
    "key_type": "SYSTEM_MANAGED",
    "valid_after": "2025-04-07T17:44:27Z",
    "valid_before": "2027-04-08T14:04:44Z",
    "disabled": null
  },
  {
    "service_account": "dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com",
    "name": "projects/<gcp-project-name>/serviceAccounts/dev--ro--cloud-function@<gcp-project-name>.iam.gserviceaccount.com/keys/f93e886791317a72794dddcd72a910346c7f03b5",
    "key_type": "SYSTEM_MANAGED",
    "valid_after": "2025-04-07T17:44:27Z",
    "valid_before": "2027-04-19T02:33:30Z",
    "disabled": null
  }
]
```

---

```console
User-Managed Keys Detected (Active Only):
[]
```

---

```console
IAM Key Expiration Inspection (Terraform-Managed Service Accounts)
No expired or expiring keys found (within 30 days).
```
