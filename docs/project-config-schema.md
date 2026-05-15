# Project Configuration Schema

Each vended repository is declared using one YAML file in `projects/configs/`.

## Source of Truth

- Discovery: `projects/main.tf` reads all `*.yaml` under `projects/configs/`.
- Validation: required values and shape checks are enforced before module creation.

## Required Fields

- `repo_name` (string)
- `description` (string)

## Optional Fields

- `additional_topics` (list(string), default `[]`)
- `enable_branch_protection` (bool, default `true`)
- `deploy_to_azure` (bool, default `true`)
- `update_branch` (string, optional)
- `enable_push_ruleset` (bool, default `false`)
- `enable_code_scanning_gate` (bool, default `true`)

## Example

```yaml
repo_name: "example-repo"
description: "Example vended repository"
additional_topics:
  - terraform
  - github
enable_branch_protection: true
deploy_to_azure: true
update_branch: "chore/vending-updates"
enable_push_ruleset: false
enable_code_scanning_gate: true
```

## Validation Expectations

- Repository names should follow GitHub naming conventions
- Configuration should be syntactically valid YAML
- Optional fields should use expected data types
- `deploy_to_azure` must be boolean when provided
- `update_branch` must be string or null when provided

## Azure Behavior Matrix

- `deploy_to_azure: true`
  - Entra identity resources are created.
  - GitHub Actions Azure secrets are injected.
- `deploy_to_azure: false`
  - Azure resources and Azure secrets are skipped.

## Security Defaults Guidance

- Keep `enable_branch_protection: true` for PR-gated delivery.
- Keep `enable_code_scanning_gate: true` unless temporarily waived for bootstrapping.
- Enable `enable_push_ruleset` only for repositories that support push rulesets.
