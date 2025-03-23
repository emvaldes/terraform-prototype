# Script: `inspect-autoscaling.shell`

**Version:** `0.1.0`

**Purpose:**
This script inspects the current autoscaling configuration and status of a GCP Managed Instance Group (MIG). It is designed for platform operators and infrastructure engineers to quickly audit the scaling behavior and policies attached to compute workloads deployed via Terraform.

## Location
`scripts/manage/inspect-autoscaling.shell`

## Execution Context
- Must be executed in a shell environment with `gcloud` installed and authenticated.
- Assumes user has viewer or editor permissions for Compute Engine resources in the specified GCP project.
- Intended for interactive use or inclusion in operational runbooks.

## Functional Summary
The script performs the following core actions:

1. **Identifies the Autoscaler**
   - Uses the `gcloud compute instance-groups managed list` command to extract the name of the MIG and associated autoscaler.
   - Relies on consistent naming conventions for identifying the target group.

2. **Describes the Autoscaling Policy**
   - Executes `gcloud compute instance-groups managed describe` and `gcloud compute autoscalers describe` to show configuration such as:
     - Minimum and maximum instance counts
     - Target CPU utilization
     - Cooldown periods and metrics

3. **Reports Current Status**
   - Displays the number of currently running instances
   - Prints the autoscaling policy as JSON or tabular output for deeper visibility
   - Highlights whether the autoscaler is actively managing the group

## Technical Highlights
- **Chained CLI Commands:** Combines `instance-groups` and `autoscalers` to produce a full picture
- **Human-Readable Output:** Useful for debugging scaling anomalies or validating production policies
- **Zone-Scoped Analysis:** Autoscaler descriptions are scoped to the zone; script may be expanded for regional groups

## Dependencies
- `gcloud` CLI must be installed and authenticated
- Compute Engine API must be enabled
- Autoscaler must be previously configured via Terraform or manual `gcloud` operations

## Example Usage
```bash
chmod +x scripts/manage/inspect-autoscaling.shell
./scripts/manage/inspect-autoscaling.shell
```

## Extension Opportunities
- Accept zone or group name as an argument
- Output results in JSON format for automated log parsing or dashboards
- Validate autoscaler existence before inspection to avoid failure
- Add contextual colorized output for scaling thresholds or violations

## Summary
`inspect-autoscaling.shell` provides a compact diagnostic interface for reviewing the status and parameters of autoscaling on GCP Managed Instance Groups. It is valuable for monitoring, debugging, and tuning infrastructure elasticity in real-world workloads.

---

```console
$ ./scripts/manage/inspect-autoscaling.shell ;
```

```console
[Inspecting Autoscaling in Workspace: dev]
[Target Configuration: ./configs/targets/dev.json]
-rw-r--r--@ 1 emvaldes  staff  221 Apr  4 13:06 ./configs/targets/dev.json
```

```json
{
    "id": "dev",
    "name": "development",
    "description": "Development environment",
    "region": "west",
    "type": "micro",
    "policies": {
        "autoscaling": "basic",
        "stressload": "low"
    }
}
```

```console
[Policies Configuration: ./configs/policies.json]
-rw-r--r--@ 1 emvaldes  staff  1895 Apr  4 20:06 ./configs/policies.json

[Target Configuration: ./configs/targets/dev.json]

[Stressload Key: low]
[Stressload Configuration: {
  "duration": 60,
  "threads": 250,
  "interval": 0.04,
  "requests": 10000
}]

[Stressload Duration: 60]
[Stressload Concurrency: 250]
[Stressload Interval: 0.04]
[Stressload Requests: 10000]

[Phase Duration: 15]
[Load Balancer IP: 34.8.19.233]
[Target URL: http://34.8.19.233]
[GCP Project ID: <gcp-project-name>]
[GCP Region: us-west2]
[Managed Instance Group: https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/regions/us-west2/instanceGroups/dev--web-servers-group]
[MIG Name: dev--web-servers-group]

[Autoscaling Key: basic]
[Autoscaling Configuration: {
  "min": 1,
  "max": 2,
  "threshold": 0.6,
  "cooldown": 60
}]
[Autoscaling Minimum: 1]

Running stress test against: http://34.8.19.233
Stress Level: low | Threads: 250 | Duration: 60s | Interval: 0.04s | Requests: 10000
[Phase: Burst Load] Duration: 15s | Concurrency: 500

[Inspecting Instances in MIG: dev--web-servers-group]
Current instances running: 1
```

```json
[
  {
    "currentAction": "NONE",
    "id": "1747512472322793130",
    "instance": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-c/instances/dev--web-server-bn6l",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-bn6l",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
    }
  }
]
```

```console
Summary:

  Total:	15.0719 secs
  Slowest:	2.6772 secs
  Fastest:	0.0166 secs
  Average:	0.0677 secs
  Requests/sec:	7366.0350

  Total data:	6890065 bytes
  Size/request:	62 bytes

Response time histogram:
  0.017 [1]	      |
  0.283 [109827]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.549 [844]	    |
  0.815 [176]	    |
  1.081 [112] 	  |
  1.347 [30]	    |
  1.613 [8]     	|
  1.879 [7]     	|
  2.145 [7]     	|
  2.411 [0]     	|
  2.677 [8]     	|


Latency distribution:
  10% in 0.0235 secs
  25% in 0.0266 secs
  50% in 0.0797 secs
  75% in 0.0897 secs
  90% in 0.0961 secs
  95% in 0.1011 secs
  99% in 0.3154 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0003 secs, 0.0166 secs, 2.6772 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0003 secs
  resp wait:	0.0669 secs, 0.0166 secs, 2.6771 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0013 secs

Status code distribution:
  [200]	109775 responses
  [502]	1245 responses
```

```console
[Phase: Sustained Pressure] Duration: 15s | Concurrency: 250

[Inspecting Instances in MIG: dev--web-servers-group]
Current instances running: 1
```

```json
[
  {
    "currentAction": "NONE",
    "id": "1747512472322793130",
    "instance": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-c/instances/dev--web-server-bn6l",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-bn6l",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
    }
  }
]
```

```console
Summary:

  Total:	15.0322 secs
  Slowest:	1.1089 secs
  Fastest:	0.0163 secs
  Average:	0.0341 secs
  Requests/sec:	7326.8821

  Total data:	6681111 bytes
  Size/request:	60 bytes

Response time histogram:
  0.018 [1]	    |
  0.042 [32783]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.066 [836]	  |■
  0.091 [21]	  |
  0.115 [52]	  |
  0.139 [44]	  |
  0.164 [18]	  |
  0.188 [1]	    |
  0.212 [304]	  |
  0.236 [3129]	|■■■■
  0.261 [816]	  |■


Latency distribution:
  10% in 0.0226 secs
  25% in 0.0250 secs
  50% in 0.0273 secs
  75% in 0.0303 secs
  90% in 0.2136 secs
  95% in 0.2234 secs
  99% in 0.2432 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0002 secs, 0.0178 secs, 0.2606 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0004 secs
  resp wait:	0.0496 secs, 0.0178 secs, 0.2606 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0007 secs

Status code distribution:
  [200]	37953 responses
  [502]	52 responses
```

```console
[Phase: Cooldown] Duration: 15s | Concurrency: 125

[Inspecting Instances in MIG: dev--web-servers-group]
Current instances running: 2
```

```json
[
  {
    "currentAction": "NONE",
    "id": "4948940550269916065",
    "instance": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-a/instances/dev--web-server-n1k6",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-n1k6",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
    }
  },
  {
    "currentAction": "NONE",
    "id": "1747512472322793130",
    "instance": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-c/instances/dev--web-server-bn6l",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-bn6l",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
    }
  }
]
```

```console
Summary:

  Total:	15.0303 secs
  Slowest:	0.1812 secs
  Fastest:	0.0166 secs
  Average:	0.0275 secs
  Requests/sec:	4540.3055

  Total data:	4032011 bytes
  Size/request:	59 bytes

Response time histogram:
  0.018 [1]	    |
  0.038 [17780]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.057 [225]	  |■
  0.077 [5]	    |
  0.097 [35]	  |
  0.117 [24]	  |
  0.136 [46]	  |
  0.156 [265]	  |■
  0.176 [1377]	|■■■
  0.196 [768]	  |■■
  0.216 [22]	  |


Latency distribution:
  10% in 0.0242 secs
  25% in 0.0268 secs
  50% in 0.0290 secs
  75% in 0.0316 secs
  90% in 0.1571 secs
  95% in 0.1663 secs
  99% in 0.1893 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0001 secs, 0.0177 secs, 0.2156 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0001 secs
  resp wait:	0.0453 secs, 0.0177 secs, 0.2156 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0005 secs

Status code distribution:
  [200]	20545 responses
  [502]	3 responses
```

```console
Stressload test complete.
```
