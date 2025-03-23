## Clarifications and Additions

### Outdated or Inaccurate Documentation
Extensibility → Add Cloud Provider

Current Text:

Update project.json, add to configs/providers/*.json
#### Clarification: AWS and Azure config stubs (aws.json, azure.json) exist, but no Terraform modules exist yet. Updated to reflect partial provider support.

Terraform Outputs

Current Text:

Each module defines standard Terraform outputs...
#### Clarification: Modules do expose outputs, but outputs.json structure and expected keys are not standardized. Sample output keys should be shown (instance_ips, backend_service_name, etc.).

Cloud Function Security

Current Text:

All functions can be auto-destroyed after test workflows
#### Correction: Auto-destruction is not implemented in terraform.yaml or post-deploy logic. This line is retained with annotation: “Planned for future CI/CD integration.”

Apache Script (apache-webserver.shell)

Current Text:

...simulate HTTP traffic under various network load conditions.
#### Correction: It initializes Apache web servers for VM startup — no stress generation. Reworded as: “Used to bootstrap VMs with a basic web server. Not a traffic simulator.”

State Management → IAM Binding

Current Text:

...RBAC-based IAM binding if enabled via storage.bucket.rbac
#### Clarification: Conditional IAM logic exists in locals.tf, but modules/gcp/storage should be reviewed to ensure full rbac: true logic is respected. Annotated as: “Requires verification in storage module”.

---

### Missing But Implemented
Group-Based Credential Filtering

#### New Section Added under Profiles / IAM Management:

The system supports group_credentials mapping using the group key in profiles.json. Terraform locals dynamically extract profiles by group, allowing environment-specific RBAC enforcement.
State Inspection & Local Conversion

#### New Section under Terraform State Management:

The script configure-backend.shell automatically downloads .tfstate per workspace and converts it into JSON (.local/). This enables audit trails and simplified debugging via jq.
Developer Docs (scripts/docs/)

#### New Mention under Automation Layer:

Human-readable documentation helpers are available in scripts/docs/*.md, covering script usage, backend management, and inspection tools.
Dynamic Tagging Logic

#### Expanded in Tagging Section (under Key Features):

Tags are applied based on rules in tagging.json, with conditional logic for fixed vs. workspace-scoped values. The tagging engine supports nested tags per provider and resource type.
Terraform Init Automation

#### Mentioned under Execution Flow:

Functions like initialize_terraform and create_workspaces automate init, backend wiring, and workspace creation. These are CLI entrypoints for setting up new environments.

---

### Not Implemented Yet
Multi-Cloud Module Support

#### Status: Only gcp modules are implemented under modules/gcp. No modules/aws/ or modules/azure/ exist. This is noted in both Extensibility and Project Summary sections as “stubbed only”.

CI/CD Modes → Artifact Mode

#### Status: No logic found in terraform.yaml that uploads ZIP artifacts. Updated to: “Planned. ZIP packaging is handled locally but not integrated into CI/CD pipeline yet.”

CI/CD Modes → Test-only Mode

#### Status: No short-circuit logic in workflows to do plan → inspect → destroy. Annotated under “CI/CD Modes” as: “Planned for future testing stages.”

Auto-destruction Logic

#### Status: No script or workflow automates post-deploy destroy or TTL-based teardown. Annotated with “Feature not implemented yet — destroy must be manual.”

Stressload Level in CI

#### Status: policies.json defines levels, but they are not parameterized in GitHub workflow. Updated under Stress Test Mode: “Currently not wired into GitHub input parameters.”

---

### Outdated or Inaccurate – Now Clarified
- Cloud provider support clarified as partial (only gcp fully implemented).
- Terraform output details now annotated with notes on actual output structure.
- Cloud Function "auto-destroy" line marked as planned—not yet implemented.
- Apache webserver script described correctly as a startup script, not a traffic generator.
- Conditional rbac binding noted as present but pending verification in module logic.

### Missing But Implemented – Now Documented
-  group_credentials filtering logic (based on profiles.json)
-  .tfstate to .json conversion and .local/ backups
-  scripts/docs/ markdown files for operational usage
-  Dynamic tagging logic based on workspace + tag.fixed
-  Shell functions like initialize_terraform and create_workspaces

### Not Implemented Yet – Now Annotated
-  AWS/Azure modules: only config stubs, no infra code
-  Artifact Mode in CI/CD: ZIP archive exists, not wired into GitHub Actions
-  Test-only CI/CD Mode: no short-run deploy/test/destroy implemented
-  No auto-destroy TTL in workflows
-  stressload level not exposed in GitHub Action parameters
