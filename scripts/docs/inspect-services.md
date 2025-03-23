# GCP ALB Inspection Script

## File
`scripts/inspect-services.shell`

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
./scripts/inspect-services.shell my-custom-forwarding-rule
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
================================================================================
Forwarding Rule Description: http-forwarding-rule
External IP: 34.54.181.111
Target Proxy: web-http-proxy
================================================================================
Target HTTP Proxy: web-http-proxy
URL Map: web-url-map
================================================================================
Backend Service: web-backend-service
Group Instance: web-servers-group
Group Zone: us-west2
================================================================================
Health Status - State: HEALTHY
================================================================================
Web Server HTTP Response Check
HTTP/1.1 200 OK
...
================================================================================
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
  ./scripts/inspect-services.shell | tee alb_diagnostics.log
  ```
- Store ALB inspection output as a GitHub artifact in automated workflows
- Pipe the final `curl` HTTP response to Slack/webhooks for basic uptime alerts
- Chain this script with ALB provisioning scripts for instant post-deploy checks

---

## Summary

The `inspect-services.shell` script streamlines the inspection of complex ALB configurations in GCP. It intelligently traces all load balancer components, surfaces operational metadata, and validates backend readiness through both control plane (`gcloud`) and data plane (`curl`) methods.

By reducing manual inspection and surfacing actionable diagnostics, this tool improves infrastructure reliability, accelerates debugging, and acts as a valuable part of your cloud operations toolkit.

Use it manually or as part of your deployment workflows to verify load balancer correctness before production traffic is served.
