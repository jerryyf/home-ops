<!--
# Sync Impact Report
- Version change: N/A → 1.0.0
- Modified Principles: Added 5 IaC GitOps principles.
- Added Sections: Additional Constraints, Development Workflow.
- Governance: Added amendment procedure, CI/CD compliance.
- Templates requiring update: None.
- TODOs: None.
-->

# home-ops Constitution

## Core Principles

### Declarative
All infrastructure must be defined declaratively via IaC. Manual changes are prohibited.

### Immutable
Infrastructure should never be patched in place; changes are deployed via replacement to maintain consistency.

### Versioned and Tested
IaC code is stored in git versioned, and every change must be unit‑tested, lint‑checked, and compiled before merging.

### Review & Testing
All PRs must pass automated tests, linting, and integration tests. Code reviews are mandatory.

### GitOps Workflow
Code changes go through a pull request that triggers CI. On merge, a GitOps operator reconciles the declarative state to the cluster.

## Additional Constraints
Technologies must be open source, licensed for use in a homelab. All secrets are stored in Vault. No hard‑coded credentials.

## Development Workflow
- `repo: main` is stable, deploy‑ready.
- Feature branches `feat/*` or `bug/*` are created for changes.
- PRs trigger lint, unit, integration tests.
- Approved PRs merge to main, CI deploys via ArgoCD/Flux.
- Rollbacks are possible by reverting commits.

## Governance
The constitution overrides all other practices. Any amendment must be proposed as a PR, reviewed by maintainers, and merged after CI passes. Version is incremented in semantic‑major/minor/patch order. The CI pipeline validates compliance: linting (tflint, tfsec), unit tests, Terraform plan diff with no changes in CI.

**Version**: 1.0.0 | **Ratified**: 2025-10-12 | **Last Amended**: 2025-10-12
<!-- Example: Version: 2.1.1 | Ratified: 2025-06-13 | Last Amended: 2025-07-16 -->