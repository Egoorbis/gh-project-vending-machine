# Project Config Examples

This folder is used for example project configuration snippets and conventions.

## Minimum Required Fields

- `repo_name`: target repository name
- `description`: repository description

## Common Optional Fields

- `additional_topics`: list of extra repository topics
- `enable_branch_protection`: defaults to `true`
- `deploy_to_azure`: defaults to `true`
- `update_branch`: optional branch for PR-based update proposals
- `enable_push_ruleset`: defaults to `false`
- `enable_code_scanning_gate`: defaults to `false`

## Example

```yaml
repo_name: "my-sample-repo"
description: "Sample repository from vending machine"
additional_topics:
  - terraform
  - security
enable_branch_protection: true
deploy_to_azure: true
update_branch: "chore/vending-updates"
```
