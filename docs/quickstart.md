# Quickstart

## Objective

Provision a new repository from configuration with default security controls enabled.

## Steps

1. Add a project config YAML under `projects/configs/`.
2. Commit and push changes.
3. Wait for `.github/workflows/vend-project.yml` to run.
4. Validate repository creation and configured settings.

## MVP Example (US1)

Use a config in `projects/configs/` (example shown below):

```yaml
repo_name: "us1-repo-provisioning"
description: "P1 MVP repository provisioning example created by vending machine"
additional_topics:
  - terraform
  - automation
enable_branch_protection: true
deploy_to_azure: false
enable_codeql_default_setup: true
enable_dependabot_alerts: true
enable_dependabot_security_updates: true
enable_dependabot_grouped_updates: true
enable_code_scanning_gate: false
```

## Validation

- Repository is created with expected name and description
- Branch protection state matches config
- Secret scanning is enabled by default
- CodeQL default setup is enabled by default
- Dependabot vulnerability alerts are enabled by default (malware detection)
- Dependabot automated security fixes are enabled by default
- Dependabot version updates are enabled by default for GitHub Actions, Terraform, Python, and npm
- Dependabot grouped updates are configured by default (minor/patch grouped, major/security separate)
- Re-running with unchanged config results in no duplicate resources
