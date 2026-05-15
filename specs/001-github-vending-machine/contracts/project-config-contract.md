# Contract: Project Configuration and Provisioning Compatibility

## Input Contract

Configuration files in `projects/configs/*.yaml` MUST follow:

```yaml
repo_name: string                # required
description: string              # required
additional_topics: [string]      # optional
enable_branch_protection: bool   # optional
deploy_to_azure: bool            # optional
update_branch: string|null       # optional
enable_push_ruleset: bool        # optional
enable_code_scanning_gate: bool  # optional
```

## Compatibility Contract

- Repository module MUST avoid unsupported GitHub provider resources that fail schema validation in pinned provider versions.
- Secret resource arguments MUST match the pinned provider schema; replacement arguments are only adopted when provider supports them.

## Output Contract

The root output `vending_machine_summary` MUST include traceability fields:
- config key
- repository name and URL
- deploy_to_azure state
- configured update_branch
- Azure identity presence and client id (when applicable)

## Validation Contract

- `terraform fmt` and `terraform validate` MUST pass in `projects/`.
- Precondition failures MUST identify invalid config keys explicitly.
