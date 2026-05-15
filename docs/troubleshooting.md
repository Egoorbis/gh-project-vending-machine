# Troubleshooting

## Repository Not Created

- Check workflow run logs in `.github/workflows/vend-project.yml`
- Validate Terraform plan output for provider/authentication errors
- Verify project YAML is in `projects/configs/` and is valid
- Confirm `repo_name` and `description` are both present and non-empty

## Azure Secrets Not Injected

- Confirm `deploy_to_azure: true`
- Verify Azure SPN module applied successfully
- Check GitHub token permissions to manage repository actions secrets
- Verify required backend and Azure input variables are populated in CI

## CodeQL Default Setup Not Enabled

- Check `.github/workflows/bootstrap-workflows.yml` execution logs
- Confirm `enable_codeql_default_setup` is not set to `false` in the project config
- Verify `GH_PAT` has permissions to manage repository security settings
- Validate with GitHub API: `gh api repos/<owner>/<repo>/code-scanning/default-setup`

## Dependabot Alerts or Security Updates Not Enabled

- Confirm `enable_dependabot_alerts` and `enable_dependabot_security_updates` are not set to `false`
- Check bootstrap workflow logs for `vulnerability-alerts` and `automated-security-fixes` API calls
- Validate with GitHub API:
	- `gh api repos/<owner>/<repo>/vulnerability-alerts`
	- `gh api repos/<owner>/<repo>/automated-security-fixes`

## Push Ruleset Validation Failure

- Personal account repositories cannot use push rulesets.
- Remove `enable_push_ruleset` from config or set it to `false`.
- Re-run Terraform after updating config.

## API Rate Limiting

- Retry after cooldown window
- Use smaller batches of configuration changes
- Review GitHub API usage in workflow logs
- Prefer running large vending updates in staggered PRs to reduce burst traffic

## Partial Apply Outcomes

- If repository creation succeeded but Azure provisioning failed, inspect Terraform state
- Re-run apply after fixing provider/authentication issues
- If bootstrap branch exists without PR, bootstrap workflow will recycle the branch and recreate a PR

## Validation Failures in CI

- Run locally from `projects/`:
	- `terraform fmt -check -recursive`
	- `terraform init`
	- `terraform validate`
- If a provider schema error appears, verify resources/arguments are supported by the pinned lockfile version.

## Quick Recovery Flow

1. Fix invalid config or provider mismatch in a PR.
2. Re-run `vend-project` workflow.
3. Confirm `vending_machine_summary` output includes expected repository and Azure fields.
4. Trigger bootstrap workflow and verify no extra PR churn on a second run.
