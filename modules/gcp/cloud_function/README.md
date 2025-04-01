# GCP Cloud Function Deployment via Terraform

## 🚀 Overview
This repository module enables deployment of a **2nd Gen Google Cloud Function** using **Terraform**, with full support for HTTP invocation, autoscaling backend load-testing, and GitHub Actions integration.

This README consolidates all troubleshooting, configuration steps, API prerequisites, Terraform changes, and automation plans that were required to complete the deployment.

---

## ✅ Functional Summary
- Terraform-deployed Cloud Function (Gen2)
- Automatically packages Python source code into a `.zip` file
- Invokes HTTP endpoint of Cloud Function to stress-test backend ALB
- Uses environment variable (`TARGET_URL`) to target ALB IP
- Leverages GCP-native logging (Cloud Logging)
- All APIs and IAM roles configured via script

---

## 📋 Troubleshooting Summary

| Step | Issue | Resolution |
|------|-------|------------|
| 1 | 403: Cloud Functions API not enabled | `gcloud services enable cloudfunctions.googleapis.com` |
| 2 | 400: Cloud Build API not enabled | `gcloud services enable cloudbuild.googleapis.com` |
| 3 | 403: Eventarc trigger validation failed | `gcloud services enable eventarc.googleapis.com` |
| 4 | Event-based trigger too complex | Removed `event_trigger`, switched to HTTP |
| 5 | 403 on HTTP invoke | Added IAM policy via `gcloud run services add-iam-policy-binding` |
| 6 | 500 from function | Set `TARGET_URL` via `gcloud run services update` |

---

## 🧪 Final Execution Log
```bash
$ python3 scripts/stressload/webservers/main.py
INFO - Target URL: https://dev--webapp-stress-tester-....run.app
INFO - Status Code: 200
INFO - Response Time: 0.24s
✔️ Reached autoscaled instance: dev--web-server-tv02
```

---

## 📝 Best Practices & Recommendations
- Enable all required APIs in advance (preferably automated)
- Use HTTP trigger for simplicity and easier access control
- Combine Terraform for infra + `gcloud` for post-deploy setup
- Validate environment vars like `TARGET_URL` early

---

## 📌 Roadmap
- [ ] Refactor Terraform to inject `TARGET_URL` dynamically
- [ ] Automatically detect load balancer IP from outputs
- [ ] Migrate IAM/public access configuration to Terraform (if feasible)
- [ ] Validate full GitHub workflow for reproducible deployment
