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
- `enable_codeql_default_setup` (bool, default `true`)
- `enable_dependabot_alerts` (bool, default `true`)
- `enable_dependabot_security_updates` (bool, default `true`)
- `enable_dependabot_grouped_updates` (bool, default `true`)
- `enable_code_scanning_gate` (bool, default `true`)

> **Note:** `enable_push_ruleset` is not supported for personal (consumer) GitHub accounts and will fail validation when set to `true`.


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
enable_codeql_default_setup: true
enable_dependabot_alerts: true
enable_dependabot_security_updates: true
enable_dependabot_grouped_updates: true
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

- All security features are enabled by default for personal accounts:
  - `enable_codeql_default_setup: true` - Enables CodeQL code scanning
  - `enable_dependabot_alerts: true` - Enables vulnerability alerts for malware detection
  - `enable_dependabot_security_updates: true` - Enables automated security fixes AND version updates via dependabot.yml
  - `enable_dependabot_grouped_updates: true` - Groups minor/patch updates together, major/security updates separate
- Each feature can be disabled individually by setting the corresponding field to `false`.
- `enable_push_ruleset` is not supported for personal accounts and is rejected when set to `true`.
- Keep `enable_branch_protection: true` for PR-gated delivery.
- Keep `enable_code_scanning_gate: true` unless temporarily waived for bootstrapping.
- Dependabot version updates are configured for: GitHub Actions, Terraform, Python (pip), and npm ecosystems.
