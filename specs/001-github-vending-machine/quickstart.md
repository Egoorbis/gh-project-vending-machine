# Quickstart: GitHub Repository Vending Machine

## Goal

Provision a GitHub repository with secure defaults by adding a single project configuration file.

## Prerequisites

- Access to this repository and target GitHub organization
- Required GitHub and Azure credentials configured for CI
- Terraform backend and provider credentials configured in `projects/`

## Steps

1. Create a new YAML file under `projects/configs/`.
2. Define at minimum:
   - `repo_name`
   - `description`
3. Optional controls:
   - `additional_topics`
   - `enable_branch_protection`
   - `deploy_to_azure`
   - `update_branch`
4. Commit and push your change.
5. Wait for the vending workflow to run.
6. Verify the new repository settings and secrets.

## Example

```yaml
repo_name: "sample-vended-repo"
description: "Repository created by vending machine"
additional_topics:
  - terraform
  - automation
enable_branch_protection: true
deploy_to_azure: true
```

## MVP Walkthrough (US1)

1. Add `projects/configs/us1-repo-provisioning.yaml`.
2. Commit and push to trigger the vending workflow.
3. Confirm repository `us1-repo-provisioning` is created.
4. Verify branch protection and baseline security settings are applied.
5. Re-run the workflow without config changes and confirm no duplicate resources are created.

## Verification Checklist

- Repository exists with expected name and description
- Branch protection state matches config
- Secret scanning is enabled
- If `deploy_to_azure: true`, Azure-related GitHub Actions secrets are present

## Notes

This file is updated during implementation and final validation tasks.

## Compatibility Remediation (Current Plan Update)

1. Remove/replace unsupported `github_repository_vulnerability_alerts` with provider-supported controls.
2. Resolve deprecation guidance by following arguments supported by the pinned provider version.
3. Run `terraform fmt` and `terraform validate` from `projects/`.
4. Confirm existing YAML configs (`agents-playground`, `finvibe`, `security_agent`) pass validation using default-aware checks.
