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
- `enable_code_scanning_gate`: defaults to `false`
- `enable_codeql_default_setup`: defaults to `true`
- `enable_dependabot_alerts`: defaults to `true`
- `enable_dependabot_security_updates`: defaults to `true`
- `enable_dependabot_grouped_updates`: defaults to `true`

Push rulesets are not supported in this vending machine because it targets personal (consumer) GitHub accounts.

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
enable_codeql_default_setup: true
enable_dependabot_alerts: true
enable_dependabot_security_updates: true
enable_dependabot_grouped_updates: true
```
