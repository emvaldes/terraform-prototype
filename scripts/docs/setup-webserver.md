# Web Server Bootstrap Script

## File
`scripts/setup-webserver.shell`

## Version
`0.1.0`

---

## Purpose

This shell script automates the installation and configuration of a lightweight web server, making it ideal for use as a **GCP startup script** on newly provisioned virtual machine instances. It is intended for environments that are deployed behind a **Google Cloud Platform HTTP(S) Load Balancer (ALB)** and need an immediate, verifiable endpoint.

The script is optimized for **Debian-based VM images** and ensures each instance starts with a fully operational Apache HTTP server and a custom HTML landing page. This setup helps engineers confirm that instances are correctly deployed, reachable through the load balancer, and functioning as expected.

It can be used across development, staging, and production environments to verify infrastructure readiness during automated provisioning, testing, and scaling.

---

## Features

- Compatible with Debian and Ubuntu base images in GCP
- Automatically updates system package listings using `apt update`
- Installs Apache2 web server via the system package manager
- Starts the Apache service and configures it to auto-start on boot using `systemctl`
- Writes a unique, hostname-based message to `/var/www/html/index.html`
- Verifies that the instance can serve traffic on port 80 immediately after startup
- Non-interactive and idempotent — safe to run on repeat launches or instance restarts

---

## Usage

### As a GCP Startup Script
The most common usage is as a startup script in an instance template:

```hcl
metadata = {
  startup-script = file("${path.module}/scripts/setup-webserver.shell")
}
```

This configuration ensures the script runs automatically when new instances are created as part of a Managed Instance Group (MIG).

### 💻 Manual Execution
You can also run the script manually for local testing or remote configuration:

```bash
chmod +x setup-webserver.shell
./setup-webserver.shell
```

This approach is useful for manually reprovisioned environments or SSH-based debugging workflows.

---

## Output

The script writes an HTML file at:
```bash
/var/www/html/index.html
```

The content of the page is dynamically generated based on the server’s hostname:
```html
<h1>Server web-server-ph2z is running behind ALB</h1>
```

This output is particularly helpful when testing load balancing behavior, such as distribution policies, failover, and health checks. By returning each instance’s hostname, it’s easy to confirm which backend served the HTTP response.

---

## Use Cases

- **Infrastructure Validation**: Quickly verify that new instances respond to HTTP traffic as expected.
- **Auto-Scaling MIGs**: Used in autoscaled deployments to ensure all ephemeral VMs launch with a valid web server.
- **CI/CD Test Deployments**: Automate web server setup for ephemeral environments created during integration tests.
- **Load Balancer Smoke Testing**: Validate that all components in the ALB → MIG → VM path are functioning.
- **Training & Demonstration**: Display a dynamic, self-labeling web page for hands-on cloud workshops or demos.
- **Debugging or Recovery**: Redeploy the script to reinitialize web server components after corruption or misconfiguration.

---

## Summary

The `setup-webserver.shell` script provides a lightweight, reliable mechanism for standing up Apache web servers across GCP-managed VM instances. It is designed to be infrastructure-safe, restart-tolerant, and cloud-native in behavior.

Its primary utility lies in providing visual, programmatic confirmation that backend compute infrastructure is alive, accessible, and correctly configured behind a Google Cloud Load Balancer. Whether you’re building production-ready services or standing up demo environments, this script ensures that your instances are ready to serve traffic from the moment they come online.

Use it in automated pipelines, templates, or manual deployments to streamline web server provisioning and reduce setup time.
