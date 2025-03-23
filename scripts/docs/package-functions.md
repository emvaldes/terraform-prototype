# Script: `package-functions.shell`

**Version:** `0.1.0`

**Purpose:**
This script prepares and packages the source code for one or more Google Cloud Functions into a `.zip` archive, making it ready for deployment via Terraform or manual `gcloud` CLI commands. It automates the zipping process to ensure all required files are bundled properly for GCP’s Cloud Functions Gen2 upload requirements.

## Location
`scripts/manage/package-functions.shell`

## Execution Context
- Intended for local execution within a development or CI/CD pipeline context
- Assumes the function source code is stored in a standard project path such as `scripts/stressload/webservers/`
- The resulting `.zip` is expected to be referenced in Terraform modules or deployment workflows

## Functional Summary
1. **Navigates to Source Directory**
   - Uses `pushd` to enter the Cloud Function source path
   - Typically: `scripts/stressload/webservers/`

2. **Creates a Zip Archive**
   - Uses the `zip` command to recursively archive `main.py` and `requirements.txt`
   - Output file is placed in `packages/stressload-webservers.zip`
   - Ensures no unrelated or extraneous files are included

3. **Returns to Root Path**
   - Uses `popd` to revert the shell context to the caller directory

4. **Confirmation Message**
   - Echoes success message upon creation of the archive

## Technical Highlights
- **Reproducibility:** The script ensures a clean, consistent artifact is generated for every run
- **Path-Independent:** Uses relative paths to work regardless of shell's starting location
- **Terraform Compatibility:** Output zip path is hardcoded to match `cloud_function` module expectations

## Dependencies
- `zip` utility must be installed
- Source code files (`main.py`, `requirements.txt`) must exist and be valid

## Example Usage
```bash
chmod +x scripts/manage/package-functions.shell
./scripts/manage/package-functions.shell
```

## Extension Opportunities
- Parameterize source and destination paths
- Validate Python syntax or `requirements.txt` before packaging
- Automatically hash or version tag the output filename for traceability
- Integrate with a Makefile or GitHub Action workflow step

## Use Cases
- **Terraform Cloud Function Deployment:** Zip artifact is passed to a Terraform module for deployment to GCP
- **Pre-Deployment Automation:** Ensures code is cleanly packaged before infrastructure workflows begin
- **Local Development Testing:** Developers can run this to verify contents and inspect the archive manually

## Summary
The `package-functions.shell` script automates the critical packaging step for deploying Python-based Cloud Functions on GCP. It guarantees the right files are zipped in the right format, enforces repeatability, and fits seamlessly into Terraform or CI-driven infrastructure pipelines. It is lightweight, targeted, and essential for reducing human error during deployment preparation.

---

```bash
$ ./scripts/manage/inspect-autoscaling.shell ;
/Users/emvaldes/.repos/github/terraform/prototype
```

```bash
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

```bash
[Target Configuration: ./configs/targets/dev.json]

[Policies Configuration: ./configs/policies.json]
-rw-r--r--@ 1 emvaldes  staff  1895 Apr  4 20:06 ./configs/policies.json

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
[Load Balancer IP: 34.107.252.198]
[Target URL: http://34.107.252.198]
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

Running stress test against: http://34.107.252.198
Stress Level: low | Threads: 250 | Duration: 60s | Interval: 0.04s | Requests: 10000
```

```json
[Phase: Burst Load] Duration: 15s | Concurrency: 500
[Inspecting Instances in MIG: dev--web-servers-group]
Current instances running: 2

[
  {
    "currentAction": "NONE",
    "id": "3429716016725017986",
    "instance": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-a/instances/dev--web-server-5lk0",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-5lk0",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250405185002444400000001"
    }
  },
  {
    "currentAction": "NONE",
    "id": "3558226755390849742",
    "instance": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-c/instances/dev--web-server-dhz2",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-dhz2",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250405185002444400000001"
    }
  }
]
```

```bash
Summary:

  Total:	15.0900 secs
  Slowest:	5.4277 secs
  Fastest:	0.0173 secs
  Average:	0.0791 secs
  Requests/sec:	6302.1139
  
  Total data:	5723044 bytes
  Size/request:	60 bytes

Response time histogram:
  0.017 [1]	    |
  0.558 [93581] |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  1.099 [1136]	 |
  1.640 [214]	 |
  2.181 [76]	 |
  2.723 [37]	 |
  3.264 [24]	 |
  3.805 [10]	 |
  4.346 [1]	    |
  4.887 [9]	    |
  5.428 [10]	 |

Latency distribution:
  10% in 0.0230 secs
  25% in 0.0254 secs
  50% in 0.0293 secs
  75% in 0.0724 secs
  90% in 0.1299 secs
  95% in 0.2804 secs
  99% in 0.7065 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0004 secs, 0.0173 secs, 5.4277 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0003 secs
  resp wait:	0.0779 secs, 0.0173 secs, 5.3925 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0004 secs

Status code distribution:
  [200]	94688 responses
  [502]	411 responses

...
```

```json
[Phase: Recovery] Duration: 15s | Concurrency: 62
[Inspecting Instances in MIG: dev--web-servers-group]
Current instances running: 2

[
  {
    "currentAction": "NONE",
    "id": "3429716016725017986",
    "instance": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-a/instances/dev--web-server-5lk0",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-5lk0",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250405185002444400000001"
    }
  },
  {
    "currentAction": "NONE",
    "id": "3558226755390849742",
    "instance": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/zones/us-west2-c/instances/dev--web-server-dhz2",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-dhz2",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/<gcp-project-name>/global/instanceTemplates/dev--web-server-template--20250405185002444400000001"
    }
  }
]
```

```bash
Summary:

  Total:	15.0323 secs
  Slowest:	0.1837 secs
  Fastest:	0.0173 secs
  Average:	0.0274 secs
  Requests/sec:	2257.2084
  
  Total data:	2001929 bytes
  Size/request:	59 bytes

Response time histogram:
  0.017 [1]	    |
  0.034 [33432] |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.051 [434]	 |■
  0.067 [0]	    |
  0.084 [21]	 |
  0.100 [25]	 |
  0.117 [17]	 |
  0.134 [0]	    |
  0.150 [0]	    |
  0.167 [0]	    |
  0.184 [1]	    |

Latency distribution:
  10% in 0.0234 secs
  25% in 0.0258 secs
  50% in 0.0277 secs
  75% in 0.0291 secs
  90% in 0.0306 secs
  95% in 0.0316 secs
  99% in 0.0360 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0001 secs, 0.0173 secs, 0.1837 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0003 secs
  resp wait:	0.0273 secs, 0.0172 secs, 0.1837 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0003 secs

Status code distribution:
  [200]	33931 responses
```

```bash
Stressload test complete.
```
