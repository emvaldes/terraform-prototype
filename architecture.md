# Deployment as a Service (DaaS) Framework - Architecture Overview

## 1. Introduction
This framework defines a **multi-tier, loosely-coupled orchestration platform** for executing infrastructure deployments in a **cloud-agnostic** manner. It is designed to deliver **Deployment as a Service (DaaS)** capabilities through GitHub Actions, allowing modular, testable, and platform-flexible operations.

## 2. Architectural Layers

### 2.1 Front-Tier: Orchestration Interface
This is the **entry-point workflow**, responsible for initiating and coordinating the deployment lifecycle. It is:
- **Platform-agnostic**: unaware of cloud specifics.
- **Stateless and declarative**: delegates actions to abstracted modules.
- **Responsible for**:
  - Receiving user input (cloud target, action type, environment).
  - Creating a **primitive master JSON object**.
  - Passing this object through the deployment pipeline.

### 2.2 Middle-Tier: Operational Brokers
These are **modular dispatchers** that evaluate the request and delegate execution to specific cloud-provider modules.
- **Specialized by action domain**, e.g., account management, backend setup.
- Dynamically route to cloud-specific implementations based on the `cloud` field in the shared JSON object.
- **Do not execute operations themselves** — they are pure brokers.

### 2.3 Backend-Tier: Provider-Specific Executors
These workflows are **cloud-specific implementations** (e.g., `credentials-gcp`, `credentials-azure`).
- Self-contained and unit-testable.
- May use platform-specific tools (e.g., Bash for GCP, PowerShell for Azure).
- Responsible for:
  - Actual setup of credentials/accounts.
  - Generating encrypted secrets.
  - Populating/enriching the master JSON object.


## 3. Master Deployment Context: `application.json`
A **single, persistent JSON object** travels across all layers, collecting and exposing data consistently. It functions as a normalized data structure and central point of truth.

### 3.1 Characteristics:
- **Created once** in the front-tier.
- **Extended by each module** with enriched results.
- **Portable**: shared using GitHub artifact upload/download.
- **Secure**: sensitive fields are encrypted inline using a deterministic mechanism.

### 3.2 Sample Schema:
```json
{
  "cloud": "gcp",
  "workspace": "staging",
  "terraform": {
    "log_level": "INFO"
  },
  "context": {
    "gcp": {
      "project_id": "my-project",
      "region": "us-central1",
      "zone": "us-central1-a"
    },
    "aws": {},
    "azure": {}
  },
  "components": {
    "account": {
      "credentials": {
        "encrypted": true,
        "path": ".secrets/credentials.gpg"
      }
    }
  },
  "signatures": [
    "setup::front-tier",
    "account-config::middle-tier",
    "credentials-gcp::backend"
  ]
}
```

### 3.3 Signature Chaining:
Each tier adds a digital signature or state marker. This allows the front-tier to validate the progress and state of execution (like TCP ACKs).


## 4. Design Principles

### 4.1 Separation of Concerns
Each layer has a focused responsibility:
- **Front-tier** delegates.
- **Middle-tier** decides.
- **Backend-tier** executes.

### 4.2 Data Normalization
All environment configurations, results, and identifiers are stored in `application.json`, not `GITHUB_ENV`. This removes dependency on ephemeral runner state and enhances portability.

### 4.3 Encryption Discipline
Sensitive data (e.g., credentials) is injected encrypted in the JSON object. Decryption is only possible by:
- Known consumers.
- With access to pre-shared or repo-defined key material.

### 4.4 Modularity and Unit Testing
All backend components are self-contained and support:
- Local execution for testing.
- Dry-run modes.
- Deterministic output injected into `application.json`.

### 4.5 Hybrid Language Support
Backend modules may be implemented in Bash, PowerShell, etc., depending on the target platform and operational needs.


## 5. GitHub Actions Strategy

### 5.1 Workflow Trigger
The **main orchestration workflow** is triggered manually or through a pipeline, with `inputs:` defining:
- Cloud provider
- Action type (deploy, destroy, inspect)
- Target environment

### 5.2 Execution Flow
1. **Front-tier** creates and initializes `application.json`.
2. Delegates to **middle-tier** account configuration module.
3. Middle-tier dispatches to **cloud-specific backend**.
4. Backend sets up credentials, encrypts them, injects them back.
5. The enriched `application.json` is re-uploaded.
6. Further modules (Terraform init, plan, apply, probes) consume this JSON.


## 6. Summary
This system implements a robust, modular, and extensible **infrastructure deployment framework** leveraging:
- Tiered workflow delegation
- Portable encrypted configuration context
- Unified data transport (`application.json`)
- GitHub-native execution via artifacts and composable workflows

It provides a clean, testable, scalable base to support cloud-native deployment workflows under a **Deployment-as-a-Service (DaaS)** model.

Future enhancements may include:
- Auto-signed JSON blocks with hash verification.
- Stateful workflow recovery.
- CI/CD hooks for commit-based cloud deployment lifecycles.
