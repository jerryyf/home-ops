# home-ops

Home-grown IaC for the homelab.

## Features

- Modular Terraform
- Helm charts for reusable configuration

## Core infrastructure

- K3S
- Istio
- cert-manager
- Postgres Operator
- Cloudflare

## Usage

In the terraform directory:

1. Create `backend.tfvars` to set region, bucket, and key
2. Create `terraform.tfvars` for all required variables
3. Initialize backend with `terraform init -backend-config="./backend.tfvars"`
4. Apply with `terraform apply`

