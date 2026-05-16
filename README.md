# home-ops

Home-grown Infrastructure as Code (IaC) for the homelab.

## Repository Contents

- [`docs/`](./docs): Documentation files, including architecture diagrams and setup guides.
- [`helm/`](./helm): Helm charts for reusable configuration of Kubernetes applications.
- [`scripts/`](./scripts): Utility scripts for common tasks such as observability setup.
- [`.specify/`](./.specify): Configuration for Specify, a tool for managing infrastructure as data.
- [`terraform/`](./terraform): Modular Terraform code for provisioning infrastructure on various cloud providers or on-premises.

## Core Components

The homelab setup focuses on the following core components:

- [**Istio**](https://istio.io): An open-source service mesh that provides traffic management, security, and observability for microservices.
- [**cert-manager**](https://cert-manager.io): A native Kubernetes certificate management controller that helps with issuing and renewing TLS certificates from various issuing sources.

## Usage

### Terraform Provisioning

In the [`terraform/`](./terraform) directory:

1. Create `backend.tfvars` to set the region, bucket, and key for remote state storage.
2. Create `terraform.tfvars` for all required variables (e.g., cloud provider credentials, cluster size, networking).
3. Initialize the backend with:
   ```bash
   terraform init -backend-config="./backend.tfvars"
   ```
4. Review the planned changes:
   ```bash
   terraform plan -var-file="./terraform.tfvars"
   ```
5. Apply the configuration:
   ```bash
   terraform apply -var-file="./terraform.tfvars"
   ```
