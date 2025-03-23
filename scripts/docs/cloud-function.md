## Prerequisites for Deploying GCP Cloud Functions via Terraform

To successfully deploy **Google Cloud Functions (2nd gen)** in your Terraform workflow, the following **Google Cloud APIs must be enabled manually** before running `terraform apply`. These are **not enabled by default** and Terraform **will fail** with `403` or `400` errors unless proactively addressed.

### Required GCP APIs

| API Name | Service ID | Purpose |
|-|-|-|
| Cloud Functions API | `cloudfunctions.googleapis.com`  | Core Cloud Functions (v2) provisioning |
| Cloud Build API | `cloudbuild.googleapis.com` | Builds and packages function source code |
| Eventarc API | `eventarc.googleapis.com` | Required for `event_trigger`-based functions (e.g., Pub/Sub) |
| Cloud Run API | `run.googleapis.com` | Backend execution platform for Cloud Functions v2 |

You can enable them using the following `gcloud` CLI commands:

```bash
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable eventarc.googleapis.com
gcloud services enable run.googleapis.com
```

> 🔗 Alternatively, visit the [GCP API Library Console](https://console.cloud.google.com/apis/library) and search for each API to enable them manually.

---

##### 1. **Pub/Sub Event Trigger Failed**

- **Root Cause:** Missing configuration and complexity for Pub/Sub-based event triggers
- **Resolution:** Switched from `event_trigger` to an HTTP-triggered function (via `service_config.ingress_settings = "ALLOW_ALL"`) and removed the `event_trigger` block.

##### 2. **Function Created But 403 Forbidden on Invocation**

- **Error:** HTTP 403 when invoking Cloud Function
- **Fix:** Added IAM binding to make function publicly invokable:
```bash
  $ gcloud run services \
           add-iam-policy-binding dev--webapp-stress-tester \
           --region us-west2 \
           --member="allUsers" \
           --role="roles/run.invoker"
```

##### 3. **Function Worked but Responded with 500 (TARGET_URL missing)**
- **Cause:** `TARGET_URL` env variable not set
- **Fix:** Updated Cloud Run environment with the ALB public IP:
```bash
  $ gcloud run services \
           update dev--webapp-stress-tester \
           --region us-west2 \
           --update-env-vars TARGET_URL=http://$(terraform output -raw load_balancer_ip)
```

##### 4. **Export TARGET_URL=http://$(terraform output -raw load_balancer_ip)**
```bash
  $ export TARGET_URL=http://$(terraform output -raw load_balancer_ip) ;
```

```bash
  $ python3 scripts/stressload/webservers/main.py ;

  2025-03-28 13:45:38,857 - INFO - Target URL: https://dev--webapp-stress-tester-u66fpmlp3a-wl.a.run.app
  2025-03-28 13:45:39,239 - INFO - Status Code: 403
  2025-03-28 13:45:39,240 - INFO - Response Time: 0.38s

  --- STRESS TEST RESULT ---
  {'statusCode': 403, 'responseTime': 0.38, 'body': '\n<html><head>\n<meta http-equiv="content-type" content="text/html;charset=utf-8">\n<title>403 Forbidden</title>\n</head>\n<body text=#000000 bgcolor=#ffffff>\n<h1>Error: Forbidden</h1>\n<h2>Your client does'}
```

```bash
  $ gcloud functions \
           describe dev--webapp-stress-tester \
           --gen2 \
           --region us-west2 ;

    buildConfig:
      automaticUpdatePolicy: {}
      build: projects/776293755095/locations/us-west2/builds/5f851daa-bdf0-49b8-89f3-ffb12fd53ace
      dockerRegistry: ARTIFACT_REGISTRY
      dockerRepository: projects/<gcp-project-id>/locations/us-west2/repositories/gcf-artifacts
      entryPoint: main
      runtime: python311
      serviceAccount: projects/<gcp-project-id>/serviceAccounts/776293755095-compute@developer.gserviceaccount.com
      source:
        storageSource:
          bucket: gcf-v2-sources-776293755095-us-west2
          generation: '1743193282369831'
          object: dev--webapp-stress-tester/function-source.zip
      sourceProvenance:
        resolvedStorageSource:
          bucket: gcf-v2-sources-776293755095-us-west2
          generation: '1743193282369831'
          object: dev--webapp-stress-tester/function-source.zip
    createTime: '2025-03-28T20:21:22.688304046Z'
    description: Stub Cloud Function for stress testing framework
    environment: GEN_2
    labels:
      goog-terraform-provisioned: 'true'
    name: projects/<gcp-project-id>/locations/us-west2/functions/dev--webapp-stress-tester
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
      revision: dev--webapp-stress-tester-00001-jor
      service: projects/<gcp-project-id>/locations/us-west2/services/dev--webapp-stress-tester
      serviceAccountEmail: 776293755095-compute@developer.gserviceaccount.com
      timeoutSeconds: 60
      uri: https://dev--webapp-stress-tester-u66fpmlp3a-wl.a.run.app
    state: ACTIVE
    updateTime: '2025-03-28T20:23:04.741928818Z'
    url: https://us-west2-<gcp-project-id>.cloudfunctions.net/dev--webapp-stress-tester
```

```bash
  $ gcloud run services \
           add-iam-policy-binding dev--webapp-stress-tester \
           --region us-west2 \
           --member="allUsers" \
           --role="roles/run.invoker" ;

    Updated IAM policy for service [dev--webapp-stress-tester].
    bindings:
    - members:
      - allUsers
      role: roles/run.invoker
    etag: BwYxbZ3Pj14=
    version: 1
```

```bash
  $ python3 scripts/stressload/webservers/main.py ;

    2025-03-28 14:19:24,354 - INFO - Target URL: https://dev--webapp-stress-tester-u66fpmlp3a-wl.a.run.app
    2025-03-28 14:19:26,050 - INFO - Status Code: 200
    2025-03-28 14:19:26,051 - INFO - Response Time: 1.70s

  --- STRESS TEST RESULT ---
  {'statusCode': 200, 'responseTime': 1.7, 'body': '{"body":"Error: TARGET_URL environment variable is not set.","statusCode":500}\n'}
```

```bash
  $ gcloud functions
           deploy dev--webapp-stress-tester \
           --gen2 \
           --region us-west2 \
           --update-env-vars TARGET_URL=http://34.149.217.219 ;

    ERROR: (gcloud.functions.deploy) Invalid value for [--source]: Provided source directory does not have file [main.py] which is required for [python311]. Did you specify the right source?
```

```bash
  $ python3 scripts/stressload/webservers/main.py ;

  2025-03-28 14:28:13,921 - INFO - Target URL: https://dev--webapp-stress-tester-u66fpmlp3a-wl.a.run.app
  2025-03-28 14:28:14,128 - INFO - Status Code: 200
  2025-03-28 14:28:14,128 - INFO - Response Time: 0.21s

  --- STRESS TEST RESULT ---
  {'statusCode': 200, 'responseTime': 0.21, 'body': '{"body":"Error: TARGET_URL environment variable is not set.","statusCode":500}\n'}
```

```bash
  $ terraform output ;

    cloud_function_bucket = "dev--cloud-function-bucket"
    cloud_function_name = "dev--webapp-stress-tester"
    cloud_function_region = "us-west2"
    cloud_function_url = "https://dev--webapp-stress-tester-u66fpmlp3a-wl.a.run.app"

    cloudsql_psa_range_name = "dev--cloudsql-psa-range"

    compute_instance_template = "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/global/instanceTemplates/dev--web-server-template--20250328180020144500000001"
    compute_instance_type = "e2-micro"
    compute_web_autoscaler_name = "dev--web-autoscaling"
    compute_web_server_ip = "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/regions/us-west2/instanceGroups/dev--web-servers-group"
    compute_web_servers_group = "https://www.googleapis.com/compute/v1/projects/<gcp-project-id>/regions/us-west2/instanceGroups/dev--web-servers-group"

    console_ips = [
      "35.235.240.0/20",
    ]
    devops_ips = [
      "68.109.187.94",
    ]

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

    http_forwarding_rule_name = "dev--http-forwarding-rule"
    http_health_check_name = "dev--http-health-check"

    instance_type = "e2-micro"

    load_balancer_ip = "34.149.217.219"

    nat_name = "dev--webapp-nat-config"

    private_ips = [
      "10.0.0.0/8",
    ]

    region = "us-west2"
    router_name = "dev--webapp-router"

    subnet_id = "projects/<gcp-project-id>/regions/us-west2/subnetworks/dev--webapp-subnet"

    vpc_network_id = "projects/<gcp-project-id>/global/networks/dev--webapp-vpc"

    web_backend_service_name = "dev--web-backend-service"
```

```bash
  $ gcloud functions \
           deploy dev--webapp-stress-tester \
           --gen2 \
           --region us-west2 \
           --update-env-vars TARGET_URL=http://$(terraform output -raw load_balancer_ip) ;

    ERROR: (gcloud.functions.deploy) Invalid value for [--source]: Provided source directory does not have file [main.py] which is required for [python311]. Did you specify the right source?
```

```bash
  $ terraform output -raw load_balancer_ip ;
    34.149.217.219
```

```bash
  $ gcloud functions \
           deploy dev--webapp-stress-tester \
           --gen2 \
           --region us-west2 \
           --update-env-vars TARGET_URL=http://34.149.217.219 ;

    ERROR: (gcloud.functions.deploy) Invalid value for [--source]: Provided source directory does not have file [main.py] which is required for [python311]. Did you specify the right source?
```

```bash
  $ gcloud run services \
           update dev--webapp-stress-tester \
           --region us-west2 \
           --update-env-vars TARGET_URL=http://$(terraform output -raw load_balancer_ip) ;

    ✓ Deploying... Done.
      ✓ Creating Revision...
      ✓ Routing traffic...
    Done.
    Service [dev--webapp-stress-tester] revision [dev--webapp-stress-tester-00002-zcp] has been deployed and is serving 100 percent of traffic.
    Service URL: https://dev--webapp-stress-tester-776293755095.us-west2.run.app
```

```bash
  $ python3 scripts/stressload/webservers/main.py ;

    2025-03-28 14:38:52,310 - INFO - Target URL: https://dev--webapp-stress-tester-u66fpmlp3a-wl.a.run.app
    2025-03-28 14:38:52,547 - INFO - Status Code: 200
    2025-03-28 14:38:52,547 - INFO - Response Time: 0.24s

    --- STRESS TEST RESULT ---
    {
      'statusCode': 200,
      'responseTime': 0.24,
      'body': '{
        "body": "<h1>Server dev--web-server-tv02 is running behind ALB</h1>\\n",
        "statusCode":200
      }\n'
    }
```

---

### Common Errors and Resolutions

| Error Message Snippet | Likely Cause | Fix |
|-|-|-|
| `Error 403: Cloud Functions API has not been used...` | `cloudfunctions.googleapis.com` not enabled | Enable Cloud Functions API via `gcloud` or GCP Console |
| `Error 400: Cloud Build API is not enabled in the project...` | `cloudbuild.googleapis.com` not enabled | Enable Cloud Build API |
| `Error 403: Validation failed for trigger... Eventarc API has not been used...` | `eventarc.googleapis.com` not enabled | Enable Eventarc API before deploying `event_trigger`-based functions |
| `Error 403: Could not create Cloud Run service... Cannot access API run.googleapis.com` | `run.googleapis.com` not enabled | Enable Cloud Run API before deploying Cloud Functions v2 |

---

### Best Practices

- Always **enable required APIs** before running Terraform for the first time.
- If you **change Cloud Function trigger types**, double-check API dependencies (e.g., Eventarc vs HTTP trigger).
- Document these APIs in your setup or onboarding guides to reduce friction for new users or CI/CD pipelines.
- Consider building a pre-deployment script to validate API access as part of your CI/CD workflow.

---

### Additional Notes

- These APIs are **billable** services depending on usage. Ensure your project has billing enabled.
- Enabling APIs via Terraform directly is **not currently supported** for some GCP APIs due to permission and project-scoping restrictions. Manual activation is recommended.
- GCP may take a few minutes to propagate newly enabled APIs—wait ~1-3 minutes before retrying `terraform apply` after enabling them.

---

### Example GCP Errors and Context

```console
│ Objective: Manages lightweight user-provided functions executed in response to events.
│            https://console.developers.google.com/apis/api/cloudfunctions.googleapis.com/overview?project=<gcp_project_id>
│ Warning:   The Cloud Functions API must be enabled manually before running `terraform apply`.
│            We deliberately avoid managing this via Terraform to prevent accidental service disablement, which could disrupt other cloud functions or shared infrastructure relying on the API.
```

```hcl
resource "google_project_service" "cloudfunctions" {
  service            = "cloudfunctions.googleapis.com"
  project            = var.gcp_project_id
  disable_on_destroy = false
}
```

---

```console
│ Error: Error creating function: googleapi: Error 403: Cloud Functions API has not been used in project <gcp_project_id> before or it is disabled.
|        Enable it by visiting https://console.developers.google.com/apis/api/cloudfunctions.googleapis.com/overview?project=<gcp_project_id> then retry.
|        If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.
```

```json
[
  {
    "@type": "type.googleapis.com/google.rpc.ErrorInfo",
    "domain": "googleapis.com",
    "metadata": {
      "activationUrl": "https://console.developers.google.com/apis/api/cloudfunctions.googleapis.com/overview?project=<gcp_project_id>",
      "consumer": "projects/<gcp_project_id>",
      "containerInfo": "<gcp_project_id>",
      "service": "cloudfunctions.googleapis.com",
      "serviceTitle": "Cloud Functions API"
    },
    "reason": "SERVICE_DISABLED"
  },
  {
    "@type": "type.googleapis.com/google.rpc.LocalizedMessage",
    "locale": "en-US",
    "message": "Cloud Functions API has not been used in project <gcp_project_id> before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/cloudfunctions.googleapis.com/overview?project=<gcp_project_id> then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry."
  },
  {
    "@type": "type.googleapis.com/google.rpc.Help",
    "links": [
      {
        "description": "Google developers console API activation",
        "url": "https://console.developers.google.com/apis/api/cloudfunctions.googleapis.com/overview?project=<gcp_project_id>"
      }
    ]
  }
]
```

---

```console
│ Warning: Error creating function: googleapi: Error 403: Validation failed for trigger projects/<gcp_project_id>/locations/us-west2/triggers/dev--webapp-stress-tester-935172:
|          Eventarc API has not been used in project <gcp_project_id> before or it is disabled.
|          Enable it by visiting https://console.developers.google.com/apis/api/eventarc.googleapis.com/overview?project=<gcp_project_id> then retry.
|          If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.
│
│   with module.cloud_function.google_cloudfunctions2_function.cloud_function,
│   on modules/gcp/cloud_function/main.tf line 29, in resource "google_cloudfunctions2_function" "cloud_function":
│   29: resource "google_cloudfunctions2_function" "cloud_function" {
```

### Cloud Build: Additional Dependencies

```console
│ Error 400: Cloud Build API is not enabled in the project `<gcp-project-id>
│    Enable: https://console.cloud.google.com/marketplace/product/google/cloudbuild.googleapis.com
|
| Requires: Cloud Build is a required dependency for deploying Cloud Functions (Gen2).
|           Ensure that `cloudbuild.googleapis.com` is enabled for your project. This must be done manually:
|  Warning: Failing to enable this will result in a 400 error during Terraform apply.
```

```console
> gcloud services enable cloudbuild.googleapis.com
  Operation "operations/acf.p2-776293755095-ecb233e6-206b-4c36-b9b4-3490231dc396" finished successfully.
```

---

```console
| Error 403: Validation failed for trigger projects/<gcp-project-id>/locations/us-west2/triggers/dev--webapp-stress-tester-935172
|    Enable: https://console.developers.google.com/apis/api/eventarc.googleapis.com/overview?project=<gcp-project-id>
|
| Note: When using event_trigger in google_cloudfunctions2_function, you must enable the Eventarc API (eventarc.googleapis.com) for your GCP project.
|       Terraform will fail with a 403 error if the API is missing.
```

```console
> gcloud services enable eventarc.googleapis.com ;
  Operation "operations/acat.p2-776293755095-52d85f65-2621-4f54-9c93-c4abca0e4d7b" finished successfully.
```

---

```console
│ Warning: Error creating function: googleapi: Error 403: Could not create Cloud Run service dev--webapp-stress-tester. Cannot access API run.googleapis.com in project <gcp_project_id>
│
│   with module.cloud_function.google_cloudfunctions2_function.cloud_function,
│   on modules/gcp/cloud_function/main.tf line 16, in resource "google_cloudfunctions2_function" "cloud_function":
│   16: resource "google_cloudfunctions2_function" "cloud_function" {
```

```console
> gcloud services enable run.googleapis.com --project <gcp-project-id> ;
  Operation "operations/acf.p2-776293755095-a49f4031-bea4-48f1-a9de-aa37d91f6864" finished successfully.
```
