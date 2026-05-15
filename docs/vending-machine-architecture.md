# GitHub Repository Vending Machine Architecture

## Overview

The vending machine provisions repositories from declarative YAML configs in `projects/configs/` using Terraform.

## Core Components

- `projects/main.tf`: Discovers project config files and orchestrates modules
- `modules/repository`: Creates and secures GitHub repositories
- `modules/entra-spn`: Creates Azure identities and OIDC federation for CI authentication

## Provisioning Flow

1. YAML config is added in `projects/configs/`
2. Terraform root module decodes config files
3. Repository and optional Azure identity resources are provisioned
4. Repository security defaults and secrets are applied

## Security Defaults

- Branch protection (configurable, default enabled)
- Secret scanning and push protection enabled
- OIDC-first identity model for Azure integration

## Idempotency

Re-applying unchanged configuration should produce no resource changes.

## Related Files

- `docs/workflow-bootstrapping.md`
- `.github/workflows/vend-project.yml`
- `.github/workflows/bootstrap-workflows.yml`
