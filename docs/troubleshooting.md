# Troubleshooting

## Repository Not Created

- Check workflow run logs in `.github/workflows/vend-project.yml`
- Validate Terraform plan output for provider/authentication errors
- Verify project YAML is in `projects/configs/` and is valid

## Azure Secrets Not Injected

- Confirm `deploy_to_azure: true`
- Verify Azure SPN module applied successfully
- Check GitHub token permissions to manage repository actions secrets

## CodeQL Workflow Not Present

- Check `.github/workflows/bootstrap-workflows.yml` execution logs
- Confirm template files are present in `modules/repository/templates/`
- Verify branch protection/update branch behavior in target repo

## API Rate Limiting

- Retry after cooldown window
- Use smaller batches of configuration changes
- Review GitHub API usage in workflow logs

## Partial Apply Outcomes

- If repository creation succeeded but Azure provisioning failed, inspect Terraform state
- Re-run apply after fixing provider/authentication issues
