# Project Configuration Schema

Each vended repository is declared using one YAML file in `projects/configs/`.

## Required Fields

- `repo_name` (string)
- `description` (string)

## Optional Fields

- `additional_topics` (list(string), default `[]`)
- `enable_branch_protection` (bool, default `true`)
- `deploy_to_azure` (bool, default `true`)
- `update_branch` (string, optional)
- `enable_push_ruleset` (bool, default `false`)
- `enable_code_scanning_gate` (bool, default `false`)

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
enable_code_scanning_gate: false
```

## Validation Expectations

- Repository names should follow GitHub naming conventions
- Configuration should be syntactically valid YAML
- Optional fields should use expected data types
