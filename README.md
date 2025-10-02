# home-ops

Home-grown IaC for the homelab.

## Features

- Modular Terraform
- Helm charts for reusable configuration

## Automation tooling

- Terraform
- Helm

## Core infrastructure

- K3S
- Istio
- cert-manager
- Postgres Operator
- Cloudflare

## Usage

1. Check environment variables required in `variables.tf`
2. Run `terraform init`
3. Run `terraform apply`

## Roadmap

- [x] Terraform
- [ ] Argo CD
- [x] Secret management
- [ ] DNS automation
- [ ] VM and VXLAN Terraform
- [ ] Kiali observability