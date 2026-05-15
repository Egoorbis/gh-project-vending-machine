# Feature Specification: GitHub Repository Vending Machine

**Feature Branch**: `001-github-vending-machine`

**Created**: 2026-05-15

**Status**: Draft

**Input**: User description: "I am building a vending machine for github repositories. it should deploy repositories, secrets and configure github repository setting such as github advanced security by default"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Deploy New GitHub Repository (Priority: P1)

A developer or automation system needs to create a new GitHub repository with standard configurations and Azure integration already in place, eliminating manual setup steps and human error.

**Why this priority**: Repository provisioning is the core function of the vending machine—without it, the system delivers no value. This is the MVP.

**Independent Test**: Can be fully tested by: (1) creating a new project YAML config file, (2) triggering the vending machine, (3) verifying the repository exists in GitHub with correct name, description, and topics.

**Acceptance Scenarios**:

1. **Given** a new project configuration file in `projects/configs/my-project.yaml`, **When** changes are pushed to the vending machine repository, **Then** a new GitHub repository named `my-project` is created with the specified description and topics.
2. **Given** `enable_branch_protection` is `true`, **When** the repository is created, **Then** the main branch requires pull request reviews before merge.
3. **Given** the project configuration is valid, **When** the vending machine runs, **Then** the repository is created or updated idempotently (no duplicate repositories on re-run).

---

### User Story 2 - Manage Repository Secrets and Credentials (Priority: P2)

Developers need to deploy applications that authenticate to Azure or other cloud services via GitHub Actions without storing static credentials in the repository. The vending machine must inject secrets automatically and configure keyless authentication (OIDC) when possible.

**Why this priority**: Security-critical functionality that enables safe CI/CD workflows. P2 because the vending machine can function with manual secret injection, but automation significantly improves security posture.

**Independent Test**: Can be fully tested by: (1) creating a repository with `deploy_to_azure: true`, (2) verifying an Azure Entra service principal (SPN) is created, (3) confirming GitHub Actions secrets are injected, (4) validating a GitHub Actions workflow can authenticate to Azure using those secrets.

**Acceptance Scenarios**:

1. **Given** `deploy_to_azure` is `true` in project config, **When** the repository is created, **Then** an Azure Entra SPN is provisioned with federated OIDC credentials for GitHub Actions.
2. **Given** an Azure SPN exists, **When** the repository is created, **Then** GitHub Actions secrets are injected for Azure authentication (client ID, tenant ID, subscription ID, etc.).
3. **Given** `deploy_to_azure` is `false`, **When** the repository is created, **Then** no Azure credentials or secrets are injected.

---

### User Story 3 - Configure GitHub Advanced Security (Priority: P2)

Repository security posture must be standardized across all vended repositories. GitHub Advanced Security features (secret scanning, vulnerability alerts, code scanning) should be enabled by default to detect and prevent security regressions early.

**Why this priority**: Security governance is mandatory for enterprise-grade delivery. P2 (paired with P2 secrets story) because the vending machine can deploy repos without these settings, but defaults-on behavior enforces organization policy.

**Independent Test**: Can be fully tested by: (1) creating a new repository via vending machine, (2) verifying secret scanning is enabled, (3) confirming vulnerability alerts are enabled, (4) checking that a CodeQL workflow file exists and will run on code changes.

**Acceptance Scenarios**:

1. **Given** a repository is vended, **When** it is created, **Then** secret scanning is enabled by default.
2. **Given** a repository is vended, **When** it is created, **Then** vulnerability alerts are enabled by default.
3. **Given** a repository is vended, **When** it is created, **Then** a CodeQL analysis workflow is bootstrapped for continuous security scanning.

---

### Edge Cases

- What happens when a project configuration has both `enable_branch_protection: true` and `update_branch` set? (Branch protection requires PR, so update branches are useful for proposing config changes.)
- What happens if the GitHub API returns a rate limit or temporary failure during repository creation? (Should retry with exponential backoff, not silently fail.)
- What if a repository with the same name already exists in GitHub? (Should detect and skip creation, or update existing; currently behavior is TBD.)
- What if Azure OIDC federation setup fails but GitHub repository creation succeeded? (Current behavior: needs clarification on rollback vs. partial success.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST deploy a new GitHub repository when a project configuration file is added to `projects/configs/`.
- **FR-002**: System MUST accept and validate project configuration in YAML format with required fields: `repo_name`, `description`, and optional fields: `additional_topics`, `enable_branch_protection`, `deploy_to_azure`, `update_branch`.
- **FR-003**: System MUST apply branch protection rules (require PRs, no direct pushes) to the `main` branch when `enable_branch_protection` is `true`.
- **FR-004**: System MUST enable secret scanning on all vended repositories by default.
- **FR-005**: System MUST enable vulnerability alerts on all vended repositories by default.
- **FR-006**: System MUST provision an Azure Entra service principal with federated OIDC credentials when `deploy_to_azure` is `true`.
- **FR-007**: System MUST inject GitHub Actions secrets for Azure authentication (Client ID, Tenant ID, Subscription ID, etc.) when an SPN is provisioned.
- **FR-008**: System MUST bootstrap CodeQL workflow files for security scanning into vended repositories.
- **FR-009**: System MUST support specifying additional repository topics via the `additional_topics` field in project configuration.
- **FR-010**: System MUST create or reuse an `update_branch` when specified for bootstrapping changes via PR instead of direct push.

### Constitution Alignment *(mandatory)*

**Terraform-First Delivery**: All repository and cloud identity provisioning is expressed in Terraform modules (`modules/repository`, `modules/entra-spn`) and roots (`projects/`). Project configurations drive infrastructure changes via code, not manual clicks.

**Security-By-Default**: Branch protection, secret scanning, vulnerability alerts, and CodeQL workflows are enabled by default. OIDC-based keyless authentication is preferred over static credentials for Azure integration.

**Idempotent Automation**: Repository and SPN creation/updates are idempotent; re-running the vending machine with the same configuration produces no duplicate artifacts. Workflow bootstrapping avoids re-creating branches/PRs when file content is already current.

**PR-Gated Delivery**: When branch protection is enabled, the `update_branch` mechanism allows proposing configuration changes via pull request instead of direct pushes.

**Verifiable Delivery**: Terraform plans verify resource changes before apply. Workflow bootstrapping compares file content byte-by-byte before creating updates. GitHub Actions artifacts (workflows, secrets) are traceable to configuration inputs under `projects/configs/`.

### Key Entities

- **Project Config**: YAML file in `projects/configs/` specifying repository settings, security toggles, and Azure integration flag.
- **GitHub Repository**: Provisioned entity with name, description, topics, branch protection, and security scanning enabled.
- **Azure Service Principal (SPN)**: Cloud identity provisioned under Entra ID with federated OIDC credentials for GitHub Actions authentication.
- **GitHub Actions Secret**: Injected credentials (Client ID, Tenant ID, etc.) for Azure authentication in CI/CD workflows.
- **Workflow File**: CodeQL and deployment workflow templates bootstrapped into vended repositories for security scanning and Azure deployment.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developers can provision a new GitHub repository with Azure integration in under 5 minutes via a single YAML file commit (vs. 20+ minutes of manual GitHub/Azure console clicks).
- **SC-002**: 100% of vended repositories have branch protection enabled by default (unless explicitly disabled).
- **SC-003**: 100% of vended repositories have secret scanning and vulnerability alerts enabled by default.
- **SC-004**: 100% of repositories with `deploy_to_azure: true` have a valid Azure SPN provisioned and secrets injected correctly, verified by successful test authentication.
- **SC-005**: Repository provisioning process is idempotent—running the vending machine twice with the same configuration creates no duplicate repositories or pull requests.
- **SC-006**: CodeQL workflow files are bootstrapped into all vended repositories and run on code changes (security scanning latency under 2 minutes per commit).
- **SC-007**: All repository and cloud identity changes are fully traceable to configuration files in `projects/configs/` via Terraform state and git history.

## Assumptions

- Developers have write access to the vending machine repository and GitHub organization to create repositories.
- Azure subscription and Entra ID tenant are pre-configured and accessible via stored credentials or managed identity.
- GitHub API token (PAT or app) has sufficient permissions to create repositories, manage secrets, and enable security features.
- Terraform and GitHub provider are version-compatible with infrastructure modules (terraform >= 1.0, provider versions as specified in `.terraform-versions` or similar).
- Project naming follows GitHub repository naming conventions (alphanumeric, hyphens, no spaces).
- YAML configuration files are syntactically valid; no runtime validation of schema beyond basic presence checks (assumes tools like pre-commit hooks or CI linting catch errors).
- Azure OIDC federation is the preferred authentication path for deployed applications; static credentials are acceptable only as a fallback or for legacy systems.
- The vending machine is deployed in a trusted environment (e.g., GitHub Actions runner with restricted access); secrets and credentials are never logged or exposed.
- Security scanning defaults (secret scanning, vulnerability alerts, CodeQL) are non-negotiable and cannot be disabled per-repository without explicit organizational override.
