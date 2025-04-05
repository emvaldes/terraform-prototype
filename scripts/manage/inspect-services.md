
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
Project ID: static-lead-454601-q1

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
Function Service Account: dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com
```

```json
Created Config-File:  scripts/stressload/webservers/config.json
{
  "target_url": "http://34.8.19.233",
  "project_id": "static-lead-454601-q1",
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
  "IPAddress": "34.8.19.233",
  "IPProtocol": "TCP",
  "creationTimestamp": "2025-04-05T00:49:29.444-07:00",
  "description": "",
  "fingerprint": "uFJneYVugTU=",
  "id": "9010661353678790246",
  "kind": "compute#forwardingRule",
  "labelFingerprint": "42WmSpB8rSM=",
  "loadBalancingScheme": "EXTERNAL",
  "name": "dev--http-forwarding-rule",
  "networkTier": "PREMIUM",
  "portRange": "80-80",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/forwardingRules/dev--http-forwarding-rule",
  "target": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy"
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
  "creationTimestamp": "2025-04-05T00:49:17.912-07:00",
  "fingerprint": "v7iWTG4S3HE=",
  "id": "957541139024273042",
  "kind": "compute#targetHttpProxy",
  "name": "dev--web-http-proxy",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/targetHttpProxies/dev--web-http-proxy",
  "urlMap": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map"
}

URL Map: dev--web-url-map
```

---

```console
$ gcloud compute url-maps describe dev--web-url-map --format=json ;
```

```json
{
  "creationTimestamp": "2025-04-05T00:49:06.582-07:00",
  "defaultService": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/backendServices/dev--web-backend-service",
  "fingerprint": "zqYtr-A8LqU=",
  "id": "5124259560514477725",
  "kind": "compute#urlMap",
  "name": "dev--web-url-map",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/urlMaps/dev--web-url-map"
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
      "group": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group"
    }
  ],
  "connectionDraining": {
    "drainingTimeoutSec": 300
  },
  "creationTimestamp": "2025-04-05T00:48:24.277-07:00",
  "description": "",
  "enableCDN": false,
  "fingerprint": "31mxcukkUlI=",
  "healthChecks": [
    "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check"
  ],
  "id": "6710688877563960999",
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
    "backend": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group",
    "status": {
      "healthStatus": [
        {
          "healthState": "HEALTHY",
          "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-c/instances/dev--web-server-bn6l",
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
$ gcloud compute health-checks describe dev--http-health-check --format=json --project=static-lead-454601-q1
```

```json
{
  "checkIntervalSec": 5,
  "creationTimestamp": "2025-04-05T00:47:15.337-07:00",
  "healthyThreshold": 2,
  "httpHealthCheck": {
    "port": 80,
    "proxyHeader": "NONE",
    "requestPath": "/"
  },
  "id": "5500521132553232108",
  "kind": "compute#healthCheck",
  "name": "dev--http-health-check",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/healthChecks/dev--http-health-check",
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

Waiting for web-server (34.8.19.233) response
HTTP/1.1 200 OK
Date: Sat, 05 Apr 2025 08:40:14 GMT
Server: Apache/2.4.41 (Ubuntu)
Last-Modified: Sat, 05 Apr 2025 07:50:31 GMT
ETag: "3b-6320341da7467"
Accept-Ranges: bytes
Content-Length: 59
Content-Type: text/html
Via: 1.1 google
```

---

```console
$ curl -H "Authorization: Bearer ***" https://compute.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling ;
```

```json
{
  "kind": "compute#autoscaler",
  "id": "4396418803213098664",
  "creationTimestamp": "2025-04-05T00:48:23.314-07:00",
  "name": "dev--web-autoscaling",
  "target": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroupManagers/dev--web-servers-group",
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
  "region": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/autoscalers/dev--web-autoscaling",
  "status": "ACTIVE",
  "recommendedSize": 1
}

Min Replicas: 1
Max Replicas: 2
Cooldown:     60
CPU Target:   0.6
```

---

```console
$ gcloud compute addresses describe dev--cloudsql-psa-range --global --project=static-lead-454601-q1 --format=json ;
```

```json
{
  "address": "10.96.0.0",
  "addressType": "INTERNAL",
  "creationTimestamp": "2025-04-05T00:47:37.012-07:00",
  "description": "",
  "id": "4066515063762935543",
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

Address Type: INTERNAL
Prefix Length: 16
Purpose: VPC_PEERING
Network: https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/networks/dev--webapp-vpc
```

---

```console
$ gcloud services vpc-peerings list --network=dev--webapp-vpc --project=static-lead-454601-q1 --format=json ;
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
Instance: dev--web-server-bn6l (us-west2-c)

{
  "cpuPlatform": "Intel Broadwell",
  "creationTimestamp": "2025-04-05T00:48:22.084-07:00",
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
      "source": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-c/disks/dev--web-server-bn6l",
      "type": "PERSISTENT"
    }
  ],
  "fingerprint": "yAR7hoDvMoM=",
  "id": "1747512472322793130",
  "kind": "compute#instance",
  "labelFingerprint": "vezUS-42LLM=",
  "labels": {
    "goog-terraform-provisioned": "true"
  },
  "lastStartTimestamp": "2025-04-05T00:48:30.337-07:00",
  "machineType": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-c/machineTypes/e2-micro",
  "metadata": {
    "fingerprint": "uSrnD7g0qS0=",
    "items": [
      {
        "key": "instance-template",
        "value": "projects/776293755095/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
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
  "name": "dev--web-server-bn6l",
  "networkInterfaces": [
    {
      "fingerprint": "g7AplmHbfc8=",
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
  "selfLink": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-c/instances/dev--web-server-bn6l",
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
  "zone": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-c"
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
  },
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
  }
]

Exported:
  iam_terraform_identities_json (JSON)
  iam_scoped_member="dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com"
  iam_scoped_roles_json (JSON)
  iam_profile_json (JSON)
```

---

```console
IAM Custom Roles Inspection (Full)
No custom IAM roles found in project: static-lead-454601-q1
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

---

```console
IAM Activity Logs (Terraform-Managed Identities)
Querying GCP logs for the following IAM members:
dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com
dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com
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
  },
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
    "service_account": "dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com",
    "name": "projects/static-lead-454601-q1/serviceAccounts/dev--ro--cloud-function@static-lead-454601-q1.iam.gserviceaccount.com/keys/c9df3cc9aa6e31e6c7dd51808f5f3a1d3ad85e34",
    "key_type": "SYSTEM_MANAGED",
    "valid_after": "2025-04-05T07:47:15Z",
    "valid_before": "2027-05-03T04:40:46Z",
    "disabled": null
  },
  {
    "service_account": "dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com",
    "name": "projects/static-lead-454601-q1/serviceAccounts/dev--ro--service-account@static-lead-454601-q1.iam.gserviceaccount.com/keys/1909d1b77aa54077d43115f860263d5f9a4fb985",
    "key_type": "SYSTEM_MANAGED",
    "valid_after": "2025-04-05T07:47:15Z",
    "valid_before": "2027-04-11T03:21:17Z",
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
