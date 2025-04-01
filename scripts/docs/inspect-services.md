# GCP ALB Inspection Script

## File
`./scripts/manage/inspect-services.shell`

## Version
`0.0.1`

---

## Purpose

This script provides a full diagnostic inspection of a **Google Cloud Platform (GCP) HTTP(S) Load Balancer (ALB)** by tracing its component relationships and verifying their operational state across all layers of the load balancing stack. It performs a comprehensive analysis from the forwarding rule entry point to backend VM instances, offering detailed diagnostics to support infrastructure validation, performance verification, and incident investigation.

This tool is particularly useful in complex deployments where validating ALB wiring and backend health across multiple regions and services is critical to ensuring reliability and availability.

---

## Features

- Fetches metadata for the forwarding rule, including IP address, port range, and proxy target
- Describes the associated target HTTP proxy to determine URL routing logic
- Retrieves URL map and default service mappings
- Describes backend service configuration, timeout, balancing scheme, and health checks
- Identifies the regional instance group backing the service
- Performs a backend health check using `gcloud` and extracts state of each instance
- Lists all VM instances in the instance group and provides per-instance metadata using `gcloud compute instances describe`
- Issues an HTTP `curl` test to the ALB’s public IP to verify end-to-end reachability
- Prints all relevant `gcloud` commands and pipes results through `jq` for readable JSON output
- Annotates major command sections with banners and summaries for easy terminal scanning

---

## Prerequisites

Before executing the script, ensure the following tools are installed and authenticated:

- `gcloud`: The Google Cloud CLI tool
- `jq`: Command-line JSON processor for formatting output
- `curl`: HTTP client for sending test requests to the load balancer

Also, ensure your environment is authenticated (`gcloud auth login`) and set to the correct project using `gcloud config set project`.

---

## Input

| Argument           | Description                                                   | Default                |
|--------------------|---------------------------------------------------------------|------------------------|
| `forwarding_rule`  | Name of the global forwarding rule to inspect and trace from  | `http-forwarding-rule` |

You can pass the name as a positional argument:

```bash
./scripts/manage/inspect-services.shell http-forwarding-rule
```

If no argument is provided, the script defaults to `http-forwarding-rule`.

---

## Inspection Flow

1. **Forwarding Rule Inspection**
   - Uses `gcloud compute forwarding-rules describe` with `--global` to extract:
     - IP address
     - Port range
     - Proxy target

2. **Target HTTP Proxy Resolution**
   - Resolves the proxy and fetches the associated `urlMap` URL
   - Extracts proxy name and URL map for further tracing

3. **URL Map Discovery**
   - Describes the URL map to find the backend service tied to the default route
   - Supports detecting misrouted or missing backend bindings

4. **Backend Service Introspection**
   - Lists service parameters: balancing mode, timeouts, ports, and CDN config
   - Pulls the attached instance group and linked health check resource

5. **Health Check Validation**
   - Uses `gcloud compute backend-services get-health` to show instance health
   - Displays `HEALTHY`, `UNHEALTHY`, or `UNKNOWN` statuses per instance

6. **Instance Group & VM Listing**
   - Describes all instances in the target instance group
   - Loops through each instance to show zone, machine name, and metadata

7. **Web Server HTTP Response Check**
   - Runs a `curl --head` request to the load balancer’s public IP
   - Validates the public IP is responding with HTTP 200 or other headers

Each section is clearly separated with horizontal dividers and labels in the console output.

---

## Example Output

```bash
devops: terraform (master *%=) $ ./scripts/manage/inspect-services.shell $( terraform output -raw http_forwarding_rule_name ) ;

================================================================================
Forwarding Rule Description: dev--http-forwarding-rule
gcloud compute forwarding-rules describe dev--http-forwarding-rule --global --format=json
```

```json
{
  "IPAddress": "34.49.100.242",
  "IPProtocol": "TCP",
  "creationTimestamp": "2025-03-28T21:20:55.739-07:00",
  "description": "",
  "fingerprint": "uFJneYVugTU=",
  "id": "7656238589340732360",
  "kind": "compute#forwardingRule",
  "labelFingerprint": "42WmSpB8rSM=",
  "loadBalancingScheme": "EXTERNAL",
  "name": "dev--http-forwarding-rule",
  "networkTier": "PREMIUM",
  "portRange": "80-80",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/forwardingRules/dev--http-forwarding-rule",
  "target": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/targetHttpProxies/dev--web-http-proxy"
}
```

```bash
External IP: 34.49.100.242
Target Proxy: dev--web-http-proxy

================================================================================
Target HTTP Proxy: dev--web-http-proxy
gcloud compute target-http-proxies describe dev--web-http-proxy --format=json
```

```json
{
  "creationTimestamp": "2025-03-28T21:20:43.874-07:00",
  "fingerprint": "v7iWTG4S3HE=",
  "id": "5600302830679935988",
  "kind": "compute#targetHttpProxy",
  "name": "dev--web-http-proxy",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/targetHttpProxies/dev--web-http-proxy",
  "urlMap": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/urlMaps/dev--web-url-map"
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
  "creationTimestamp": "2025-03-28T21:20:32.435-07:00",
  "defaultService": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/backendServices/dev--web-backend-service",
  "fingerprint": "GtUqxP4T9xk=",
  "id": "2388311147524312063",
  "kind": "compute#urlMap",
  "name": "dev--web-url-map",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/urlMaps/dev--web-url-map"
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
      "group": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/regions/us-west2/instanceGroups/dev--web-servers-group"
    }
  ],
  "connectionDraining": {
    "drainingTimeoutSec": 300
  },
  "creationTimestamp": "2025-03-28T21:19:49.770-07:00",
  "description": "",
  "enableCDN": false,
  "fingerprint": "HhH8KrA3Dl4=",
  "healthChecks": [
    "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/healthChecks/dev--http-health-check"
  ],
  "id": "4931091344791357962",
  "kind": "compute#backendService",
  "loadBalancingScheme": "EXTERNAL",
  "name": "dev--web-backend-service",
  "port": 80,
  "portName": "http",
  "protocol": "HTTP",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/backendServices/dev--web-backend-service",
  "sessionAffinity": "NONE",
  "timeoutSec": 30,
  "usedBy": [
    {
      "reference": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/urlMaps/dev--web-url-map"
    }
  ]
}
```

```bash
Group Instance: dev--web-servers-group
Group Region:   us-west2

================================================================================
Backend Health Status
gcloud compute backend-services get-health dev--web-backend-service --global --format=json
```

```json
[
  {
    "backend": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/regions/us-west2/instanceGroups/dev--web-servers-group",
    "status": {
      "healthStatus": [
        {
          "healthState": "HEALTHY",
          "instance": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/zones/us-west2-a/instances/dev--web-server-2hh9",
          "ipAddress": "10.0.1.2",
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
gcloud compute health-checks describe dev--http-health-check --format=json --project=<gcp-project-id>
```

```json
{
  "checkIntervalSec": 5,
  "creationTimestamp": "2025-03-28T21:18:53.399-07:00",
  "healthyThreshold": 2,
  "httpHealthCheck": {
    "port": 80,
    "proxyHeader": "NONE",
    "requestPath": "/"
  },
  "id": "7535224170629220930",
  "kind": "compute#healthCheck",
  "name": "dev--http-health-check",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/healthChecks/dev--http-health-check",
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
curl --head --connect-timeout 10 http://34.49.100.242

Waiting for web-server (34.49.100.242) response
HTTP/1.1 200 OK
Date: Sat, 29 Mar 2025 10:52:46 GMT
Server: Apache/2.4.62 (Debian)
Last-Modified: Sat, 29 Mar 2025 04:21:00 GMT
ETag: "3b-6317383a896d7"
Accept-Ranges: bytes
Content-Length: 59
Content-Type: text/html
Via: 1.1 google
```

```bash
================================================================================
Autoscaler Configuration: dev--web-autoscaling
curl -H "Authorization: Bearer ***" https://compute.googleapis.com/compute/v1/projects/<gcp-project-id>/regions/us-west2/autoscalers/dev--web-autoscaling
```

```json
{
  "kind": "compute#autoscaler",
  "id": "5713507104766741002",
  "creationTimestamp": "2025-03-28T21:19:49.291-07:00",
  "name": "dev--web-autoscaling",
  "target": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/regions/us-west2/instanceGroupManagers/dev--web-servers-group",
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
  "region": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/regions/us-west2",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/regions/us-west2/autoscalers/dev--web-autoscaling",
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
gcloud compute addresses describe dev--cloudsql-psa-range --global --project=<gcp-project-id> --format=json
```

```json
{
  "address": "10.202.0.0",
  "addressType": "INTERNAL",
  "creationTimestamp": "2025-03-28T21:19:15.013-07:00",
  "description": "",
  "id": "3515829947799882285",
  "kind": "compute#address",
  "labelFingerprint": "vezUS-42LLM=",
  "labels": {
    "goog-terraform-provisioned": "true"
  },
  "name": "dev--cloudsql-psa-range",
  "network": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/networks/dev--webapp-vpc",
  "networkTier": "PREMIUM",
  "prefixLength": 16,
  "purpose": "VPC_PEERING",
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/addresses/dev--cloudsql-psa-range",
  "status": "RESERVED"
}
```

```bash
Address Type: INTERNAL
Prefix Length: 16
Purpose: VPC_PEERING
Network: https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/networks/dev--webapp-vpc

================================================================================
PSA VPC Peering Connections
gcloud services vpc-peerings list --network=dev--webapp-vpc --project=<gcp-project-id> --format=json
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
Instance: dev--web-server-2hh9 (us-west2-a)
```

```json
{
  "cpuPlatform": "Intel Broadwell",
  "creationTimestamp": "2025-03-28T21:19:43.768-07:00",
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
      "source": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/zones/us-west2-a/disks/dev--web-server-2hh9",
      "type": "PERSISTENT"
    }
  ],
  "fingerprint": "4VZCZ1Z2h24=",
  "id": "1183915915868817968",
  "kind": "compute#instance",
  "labelFingerprint": "vezUS-42LLM=",
  "labels": {
    "goog-terraform-provisioned": "true"
  },
  "lastStartTimestamp": "2025-03-28T21:19:55.925-07:00",
  "machineType": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/zones/us-west2-a/machineTypes/e2-micro",
  "metadata": {
    "fingerprint": "qGBXlsQJVzE=",
    "items": [
      {
        "key": "instance-template",
        "value": "projects/776293755095/global/instanceTemplates/dev--web-server-template--20250329041924308300000001"
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
  "name": "dev--web-server-2hh9",
  "networkInterfaces": [
    {
      "fingerprint": "46wGexqYV0U=",
      "kind": "compute#networkInterface",
      "name": "nic0",
      "network": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/networks/dev--webapp-vpc",
      "networkIP": "10.0.1.2",
      "stackType": "IPV4_ONLY",
      "subnetwork": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/regions/us-west2/subnetworks/dev--webapp-subnet"
    }
  ],
  "satisfiesPzi": true,
  "scheduling": {
    "automaticRestart": true,
    "onHostMaintenance": "MIGRATE",
    "preemptible": false,
    "provisioningModel": "STANDARD"
  },
  "selfLink": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/zones/us-west2-a/instances/dev--web-server-2hh9",
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
    "fingerprint": "IMYPDi8hCX8=",
    "items": [
      "couchsurfing",
      "http-server",
      "ssh-access"
    ]
  },
  "zone": "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/zones/us-west2-a"
}
```

```bash
Completed the Application Load Balancer inspection.
```

---

## Use Cases

- **Post-Deployment Smoke Testing**
  - Immediately validate ALB health after infrastructure provisioning with Terraform or manual deployment

- **Service Debugging and Root Cause Analysis**
  - Identify failures in load balancing or instance reachability, especially during production incidents

- **CI/CD Gatekeeping**
  - Integrate the script into GitHub Actions or Jenkins pipelines as a quality gate before running service tests

- **Live Monitoring and Auditing**
  - Run periodically in staging/pre-prod environments to ensure routing configurations haven’t drifted or degraded

---

## Tips & Integration Ideas

- Use with `tee` to store full inspection logs:
```bash
./scripts/manage/inspect-services.shell | tee alb_diagnostics.log
```
- Store ALB inspection output as a GitHub artifact in automated workflows
- Pipe the final `curl` HTTP response to Slack/webhooks for basic uptime alerts
- Chain this script with ALB provisioning scripts for instant post-deploy checks

---

## Summary

The `./scripts/manage/inspect-services.shell` script streamlines the inspection of complex ALB configurations in GCP. It intelligently traces all load balancer components, surfaces operational metadata, and validates backend readiness through both control plane (`gcloud`) and data plane (`curl`) methods.

By reducing manual inspection and surfacing actionable diagnostics, this tool improves infrastructure reliability, accelerates debugging, and acts as a valuable part of your cloud operations toolkit.

Use it manually or as part of your deployment workflows to verify load balancer correctness before production traffic is served.
