# home-ops

Home-grown IaC for the homelab.

## Features

- Modular Terraform
- Helm charts for reusable configuration

## Core infrastructure

- Proxmox
- K3S
- Istio
- cert-manager
- Cloudflare

## Usage

In the terraform directory:

1. Create `backend.tfvars` to set region, bucket, and key
2. Create `terraform.tfvars` for all required variables
2. Create `backend.tfvars` for backend configuration
3. Initialize backend with `terraform init -backend-config="./backend.tfvars"`
4. Apply with `terraform apply`
