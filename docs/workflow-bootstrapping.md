# Workflow File Bootstrapping

## Overview

This document explains how workflow/config files and security defaults are bootstrapped to vended repositories.

## Architecture Change

Previously, workflow file bootstrapping was handled by Terraform using:
- `github_branch` resource to create update branches
- `github_repository_file` resources to commit workflow files
- `github_repository_pull_request` resource to create PRs

This approach had a critical flaw: once a PR was merged and the branch deleted, Terraform would recreate the branch and PR on the next run, even when no changes were needed.

## New Approach

Workflow bootstrapping is now handled by a GitHub Actions workflow (`.github/workflows/bootstrap-workflows.yml`) that:

1. Runs after the main "Vend new Project" workflow completes successfully
2. Can also be manually triggered via `workflow_dispatch`
3. Reads all project configurations from `projects/configs/*.yaml`
4. For each repository:
   - Checks if the repository exists
   - Reconciles repository-level security defaults through GitHub APIs
     (CodeQL default setup, Dependabot vulnerability alerts, and
     Dependabot automated security fixes)
   - Checks if workflow/config files already exist in the main branch
   - Compares existing content with template content
   - Only creates a branch and PR if updates are needed
   - Reuses the branch name `chore/vending-updates` for consistency

## Key Benefits

1. **Idempotent**: Only creates PRs when files actually need updating
2. **Smart Detection**: Compares file content before creating PRs
3. **No State Issues**: No Terraform state management for ephemeral branches
4. **Cleaner Separation**: Infrastructure (Terraform) vs. code/workflows (GitHub Actions)

## How It Works

### Content Comparison

The workflow:
1. Fetches existing workflow files from the main branch (if they exist)
2. Reads the template files from `modules/repository/templates/`
3. Compares the content byte-by-byte
4. Only proceeds if content differs or files don't exist

### Branch Management

If an update is needed:
1. Checks if the `chore/vending-updates` branch exists
2. If it exists and has an open PR, skips (PR still pending review)
3. If it exists without a PR, deletes the old branch
4. Creates a fresh branch from the latest main branch
5. Commits the updated workflow files
6. Creates a new PR

### Workflow Files Managed

1. **CI/CD Deploy** (`.github/workflows/vending-machine/deploy.yml`)
   - Only created if `deploy_to_azure` is not set to `false`
   - Calls the reusable deployment workflow

2. **Dependabot Configuration** (`.github/dependabot.yml`)
   - Created/updated when Dependabot updates are enabled
   - Enables version updates for GitHub Actions, Terraform, Python (pip), and npm ecosystems
   - Configures grouped updates (minor/patch updates grouped together, major/security updates separate)
   - Groups can be toggled on/off per repository

3. **Dependency Submission** (`.github/workflows/dependency-submission.yml`)
   - Keeps dependency graph submissions standardized

### Security Defaults Managed via API

1. **CodeQL Default Setup**
   - Enabled by default with query suite `default`
   - Can be disabled per repository

2. **Dependabot Vulnerability Alerts**
   - Enabled by default
   - Can be disabled per repository

3. **Dependabot Automated Security Fixes**
   - Enabled by default
   - Can be disabled per repository

## Configuration

Projects are configured in `projects/configs/*.yaml` files. The workflow bootstrapping system reads these files directly.

Relevant fields:
- `repo_name`: The repository to bootstrap (required)
- `deploy_to_azure`: Whether to create the deploy workflow (default: true)
- `enable_codeql_default_setup`: Whether to enable CodeQL default setup (default: true)
- `enable_dependabot_alerts`: Whether to enable Dependabot vulnerability alerts for malware detection (default: true)
- `enable_dependabot_security_updates`: Whether to enable automated security fixes and create dependabot.yml for version and security updates (default: true)
- `enable_dependabot_grouped_updates`: Whether grouped updates are enabled in `dependabot.yml` - groups minor/patch together, major/security separate (default: true)

Note: The legacy `update_branch` and `create_bootstrap_pr` fields are no longer used.

## Manual Triggering

You can manually trigger workflow bootstrapping:

1. Go to the Actions tab in the vending machine repository
2. Select "Bootstrap Workflow Files"
3. Click "Run workflow"
4. Select the branch (usually `main`)
5. Click "Run workflow"

This is useful when:
- Template files have been updated
- You want to force-update all repositories
- A previous run failed

## Troubleshooting

### PRs Not Being Created

Check:
1. Does the repository exist?
2. Are workflow files already up-to-date in main?
3. Is there already an open PR for the branch?

### Authentication Issues

The workflow uses the `GH_PAT` secret for authentication. Ensure:
1. The secret is configured in the repository
2. The PAT has sufficient permissions (repo, workflow)
3. The PAT hasn't expired

### Template Changes Not Applied

If you update template files:
1. The changes will be picked up on the next workflow run
2. You can manually trigger the workflow to apply changes immediately
3. The workflow compares file content, so only changed files trigger updates

## Future Enhancements

Possible improvements:
1. Add support for per-repository workflow customization
2. Implement automatic merging for trusted updates
3. Add workflow file versioning and change tracking
4. Create summary reports of which repositories were updated
