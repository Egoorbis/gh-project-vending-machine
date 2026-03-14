# 🚀 GitHub Repository Vending Machine

This repository automates the complete provisioning of GitHub repositories with Azure integration. Using Terraform, it orchestrates both GitHub repository creation and Azure service principal setup with federated OIDC credentials for GitHub Actions—all in one go.

## 🏗️ Architecture
- **Tooling:** Terraform (HCL)
- **GitHub:** Terraform GitHub Provider with GitHub Apps
- **Azure:** Entra ID for service principals, OIDC federation and Azure RM for role assignments
- **Security:** Automated branch protections, secret scanning, vulnerability alerts, and keyless GitHub Actions authentication

## 🛠️ How it Works
The vending machine automates a two-step process:

1. **Entra SPN Module**: Creates an Azure service principal with federated identity credentials for GitHub Actions OIDC authentication. 
   - Enables keyless authentication from GitHub Actions
   - Automatically configured for `main` branch deployments
   - Role assignments for Azure subscription access

2. **Repository Module**: Provisions a fully-configured GitHub repository
   - Optionally enforces `main` branch protection (no direct pushes, requires PR)
   - Enables secret scanning & vulnerability alerts
   - Auto-injects Azure credentials as GitHub Actions secrets
   - Configures backend state storage for Terraform deployments

3. **Projects**: Add a YAML file to `/projects/configs/` — no code changes needed!

Simply drop a new YAML file in `projects/configs/`, push, and get a fully-secured, Azure-integrated repository!

## 📂 Structure
- `/modules/entra-spn`: Creates Azure Entra service principals with OIDC federation
- `/modules/repository`: Provisions GitHub repositories with security & Azure integration
- `/projects`: Terraform root module — auto-discovers all project YAML files
- `/projects/configs`: Project definition files (one YAML file per project)

## ➕ Adding a New Project

Create a new YAML file in `projects/configs/` with your project settings:

```yaml
# projects/configs/my-new-project.yaml
repo_name: "my-new-project"
description: "A brief description of this project."
additional_topics:
  - terraform
  - my-team
enable_branch_protection: true
# update_branch: "chore/vending-updates"  # See "Running Updates" below
```

Commit and push — the CI/CD pipeline handles the rest.

### Available Configuration Options

| Field | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `repo_name` | string | *required* | Name of the GitHub repository to create |
| `description` | string | *required* | Repository description |
| `additional_topics` | list(string) | `[]` | Extra repository topics (added alongside the default ones) |
| `enable_branch_protection` | bool | `true` | Protect the `main` branch (requires PRs, no direct pushes) |
| `update_branch` | string | `null` | When set **and** `enable_branch_protection` is `true`, creates a dedicated branch for proposing updates via Pull Request. Has no effect when `enable_branch_protection` is `false`. |
| `deploy_to_azure` | bool | `true` | When `true`, creates an Entra service principal, injects Azure credentials as GitHub Actions secrets, and bootstraps an Azure deployment workflow. Set to `false` for repositories that do not need Azure integration. |

## 🔄 Running Updates on an Existing Project

When `enable_branch_protection` is `true` and you need to update a vended repository's configuration, direct pushes to `main` are blocked. To apply changes safely:

1. Set `update_branch` in the project's YAML file:

```yaml
enable_branch_protection: true
update_branch: "chore/vending-updates"
```

2. Push the change — Terraform will create the `chore/vending-updates` branch in the target repository.
3. Open a Pull Request from that branch into `main` inside the vended repository.
4. Remove `update_branch` from the YAML once the PR is merged.

## 🔓 Disabling Branch Protection

To create a repository without branch protection (e.g., for experimentation or bootstrapping):

```yaml
repo_name: "my-sandbox-repo"
description: "Sandbox repository without branch protection."
enable_branch_protection: false
```

## ☁️ Disabling Azure Integration

To create a repository without any Azure integration (no Entra SPN, no Azure secrets, no Azure deployment workflow):

```yaml
repo_name: "my-non-azure-repo"
description: "Repository that does not deploy to Azure."
deploy_to_azure: false
```

When `deploy_to_azure` is `false`:
- No Azure Entra service principal is created
- No Azure credentials are injected as GitHub Actions secrets
- No Azure deployment workflow is bootstrapped into the repository

