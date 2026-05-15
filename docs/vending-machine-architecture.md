# GitHub Repository Vending Machine Architecture

## Overview

This repository provisions GitHub repositories from declarative YAML files in
`projects/configs/` using Terraform modules and GitHub Actions workflows.

The architecture is split into two control planes:

- Infrastructure vending (Terraform): repository settings, rulesets, and optional Azure identity wiring.
- Workflow bootstrapping (GitHub Actions): synchronization of standardized workflow templates into vended repositories.

## Core Components

- `projects/main.tf`
	- Discovers and decodes project YAML files.
	- Validates required config shape and data types.
	- Filters Azure-enabled projects and wires module inputs.
- `modules/repository`
	- Creates repository resources and baseline security settings.
	- Applies branch/push rulesets and optional code-scanning merge gates.
	- Injects Azure-related GitHub Actions secrets when `deploy_to_azure = true`.
- `modules/entra-spn`
	- Creates Entra app/service principal resources for Azure-enabled projects.
	- Establishes OIDC federated credentials for push and pull-request workflows.
- `.github/workflows/vend-project.yml`
	- Runs `terraform fmt`, `terraform init`, `terraform validate`, and apply/plan logic.
	- Publishes vending summary output for traceability.
- `.github/workflows/bootstrap-workflows.yml`
	- Compares target repository workflow/config files with local templates.
	- Creates update branch and PR only when content differs.

## End-to-End Provisioning Flow

1. Add/update YAML in `projects/configs/`.
2. CI runs Terraform validation and provisioning from `projects/`.
3. Root module provisions repository and optional Azure identity.
4. Bootstrap workflow checks workflow template drift and opens PRs only when needed.

## Security Defaults

- Branch protection defaults to enabled (`enable_branch_protection`).
- Secret scanning and push protection are enabled in `security_and_analysis`.
- Dependabot security updates are enabled.
- Optional code scanning gate can require a passing CodeQL baseline before merge.

## Idempotency and Drift Resistance

- Repository topics are merged deterministically and deduplicated.
- Workflow bootstrap compares full file content before creating branches/PRs.
- Deterministic update branches avoid branch/PR churn across repeated runs.

## Validation and Traceability

- Validation gates:
	- `terraform fmt`
	- `terraform validate`
- Traceability output is exposed via `vending_machine_summary` in `projects/outputs.tf`.

## Related Files

- `docs/workflow-bootstrapping.md`
- `.github/workflows/vend-project.yml`
- `.github/workflows/bootstrap-workflows.yml`
