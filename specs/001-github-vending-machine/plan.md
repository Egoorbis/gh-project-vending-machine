# Implementation Plan: GitHub Repository Vending Machine

**Branch**: `001-github-vending-machine` | **Date**: 2026-05-15 | **Spec**: [spec.md](../../specs/001-github-vending-machine/spec.md)

**Input**: Feature specification from `specs/001-github-vending-machine/spec.md`

## Summary

Build a Terraform-driven GitHub repository vending machine that provisions repositories with secure defaults (branch protection, secret scanning, GitHub Advanced Security) and optional Azure integration (service principals, OIDC federation, secrets injection). The system reads YAML configurations from `projects/configs/`, auto-discovers projects, and provisions repositories and cloud identities idempotently.

**Current State**: Core Terraform modules and root project configuration are **already implemented** (`modules/repository/`, `modules/entra-spn/`, `projects/main.tf`). Workflow bootstrapping infrastructure is documented but integration with specification is incomplete.

**Technical Approach**: Complete specification-driven implementation by validating existing Terraform code against all functional requirements, ensuring CodeQL workflow bootstrapping integrates with idempotency gates, adding integration tests for all user stories, and creating comprehensive documentation of the vending machine architecture.

---

## Technical Context

**Language/Version**: Terraform 1.0+ (HCL)

**Primary Dependencies**:
- `github` provider (GitHub repository/ruleset/secret management)
- `azuread` provider (Azure Entra ID service principals)
- `azurerm` provider (Azure role assignments)

**Storage**: Terraform state (local or remote in Azure Storage Account)

**Testing**: `terraform plan` verification, GitHub Actions integration tests, manual validation of provisioned resources

**Target Platform**: GitHub Actions CI/CD environment (Linux/macOS runners)

**Project Type**: Infrastructure-as-code provisioning system (Terraform root module + reusable modules)

**Performance Goals**: Repository provisioning within 2-3 minutes (GitHub API latency dependent); idempotent re-runs with zero drift

**Constraints**:
- No direct pushes to `main` on vending machine repo (branch protection enforced)
- All changes via PR with Terraform plan validation
- GitHub API rate limits (max ~5000 requests/hour per user)
- Azure OIDC federation requires specific GitHub Actions context (main branch + PRs)

**Scale/Scope**:
- Initial MVP: 3-5 example projects
- Target: Scale to 50+ projects without state sprawl
- Support both Azure and non-Azure projects

---

## Constitution Check ✅

- [x] **Terraform-First Delivery**: All provisioning via Terraform modules; project configs drive infrastructure via code (no manual console clicks)
- [x] **Security-By-Default**: Branch protection, secret scanning, vulnerability alerts enabled by default; OIDC preferred over static credentials
- [x] **Idempotent Automation**: Modules support re-run with no duplicate resources; workflow bootstrapping compares content before creating branches/PRs
- [x] **PR-Gated Delivery**: Vending machine's own main branch protected; update branches for proposed repository changes
- [x] **Verifiable Delivery**: Terraform plan validation; GitHub Actions workflow content comparison; secrets traced to configuration inputs

---

## Project Structure

### Documentation (this feature)

```text
specs/001-github-vending-machine/
├── spec.md                    # User stories, requirements, success criteria
├── plan.md                    # This file (implementation plan)
├── research.md                # (Phase 0 output if needed)
├── data-model.md              # (Phase 1 output if needed)
├── quickstart.md              # (Phase 1 output)
├── contracts/                 # (Phase 1 output if needed)
├── tasks.md                   # (Phase 2 output - NOT created by this plan)
└── checklists/
    └── requirements.md        # Quality gate validation
```

### Source Code (repository root)

**Existing & Verified**:
```text
modules/
├── entra-spn/                 # Azure SPN provisioning
│   ├── main.tf               # azuread_application, azuread_service_principal, federated identity, role assignment
│   ├── variables.tf
│   └── outputs.tf
└── repository/               # GitHub repository provisioning
    ├── main.tf              # github_repository, branch protection, secret scanning, push guard, secrets
    ├── variables.tf
    └── outputs.tf

projects/                      # Root module
├── main.tf                   # Module composition, auto-discovery of configs
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
└── configs/
    ├── agents-playground.yaml   # Example projects
    ├── finvibe.yaml
    └── security_agent.yaml

.github/workflows/
└── bootstrap-workflows.yml   # (Mentioned in docs; workflow bootstrapping for CodeQL + deploy workflows)
```

**To Create/Validate**:
```text
docs/
├── vending-machine-architecture.md     # System design, data flow, how it works
├── project-config-schema.md            # YAML schema docs and examples
└── troubleshooting.md                  # Common issues and solutions

tests/
├── terraform/
│   ├── unit/                          # terraform fmt, validate
│   └── integration/                   # GitHub Actions: create test repo, verify config, cleanup
└── github-actions/
    └── test-vending-workflow.yml      # End-to-end integration test
```

**Structure Decision**: Single root module + two focused child modules. Project configs live in `projects/configs/` as YAML files; Terraform auto-discovers and provisions them. No separate environments (dev/staging/prod)—all projects are treated uniformly.

---

## Implementation Phases

### Phase 0: Validation & Gap Analysis

**Purpose**: Confirm existing Terraform implementation against specification; identify any gaps in FR coverage

**Steps**:

1. Review existing `modules/repository/main.tf` and validate coverage of:
   - FR-001: Repository deployment ✅ (github_repository resource)
   - FR-002: YAML validation ✅ (lookup/defaults in projects/main.tf)
   - FR-003: Branch protection ✅ (github_repository_ruleset + main_branch)
   - FR-004: Secret scanning ✅ (security_and_analysis.secret_scanning)
   - FR-005: Vulnerability alerts ✅ (secret_scanning_push_protection)
   - FR-006: Azure SPN ✅ (modules/entra-spn/)
   - FR-007: Secrets injection ✅ (github_actions_secret for_each loop)
   - FR-008: CodeQL workflow bootstrapping ⚠️ (NEEDS VERIFICATION — documented but may need integration)
   - FR-009: Additional topics ✅ (additional_topics parameter)
   - FR-010: Update branch ⚠️ (NEEDS VERIFICATION — documented but may need TF integration)

2. Check `modules/entra-spn/main.tf` for:
   - OIDC federation setup for main branch ✅
   - OIDC federation setup for PRs ✅
   - Role assignment (Contributor scope) ✅

3. Verify idempotency gates in Terraform (no re-creation of resources on re-apply)

4. Document any implementation gaps and plan remediation

**Deliverable**: Gap analysis report included in Phase 1 design section

---

### Phase 1: Design & Documentation

**Purpose**: Define system architecture, project config schema, and implementation contracts

**Steps**:

1. **Create Architecture Documentation** (`docs/vending-machine-architecture.md`):
   - System overview diagram (Terraform → GitHub + Azure)
   - Data flow: YAML config → module discovery → resource provisioning
   - Idempotency guarantees and drift detection
   - Workflow bootstrapping flow (CodeQL + deploy workflows)
   - Reference to bootstrap-workflows.yml for implementation details

2. **Define Project Config Schema** (`docs/project-config-schema.md`):
   - YAML structure with examples
   - Required fields: `repo_name`, `description`
   - Optional fields with defaults: `additional_topics`, `enable_branch_protection`, `deploy_to_azure`, `update_branch`, `enable_push_ruleset`, `enable_code_scanning_gate`
   - Validation rules (naming conventions, required characters)
   - Examples for different scenarios (Azure-enabled, non-Azure, with branch protection)

3. **Create Quickstart Guide** (`docs/quickstart.md`):
   - How to create a new project (5-minute walkthrough)
   - Step 1: Create YAML file in `projects/configs/`
   - Step 2: Commit and push to main
   - Step 3: GitHub Actions workflow runs Terraform
   - Step 4: Verify repository exists in GitHub
   - Step 5: (If Azure) Verify SPN created and secrets injected
   - Common configurations (templates for different use cases)

4. **Document Contracts** (if needed):
   - Input contract: YAML schema and validation
   - Output contract: Repository URLs, SPN client IDs, injected secrets
   - Error contract: How to handle failures, retry strategies

5. **Create Troubleshooting Guide** (`docs/troubleshooting.md`):
   - "Repository not created" → check Terraform plan, GitHub API errors
   - "Secrets not injected" → verify deploy_to_azure: true, check SPN provisioning
   - "CodeQL workflow not running" → verify bootstrap-workflows.yml, check branch
   - Rate limit errors and backoff strategies

---

### Phase 2: Testing & Integration

**Purpose**: Validate all user stories and requirements with automated tests

**Steps**:

1. **Terraform Validation** (local or in CI):
   - `terraform fmt -recursive` to ensure consistent formatting
   - `terraform validate` to catch syntax errors
   - `terraform plan -out=plan.tfplan` to validate resource changes before apply

2. **GitHub Actions Integration Test** (`.github/workflows/test-vending-workflow.yml`):
   - Trigger: On PR to main or manual dispatch
   - Steps:
     a. Create a temporary test project config (`test-vending-temp.yaml`)
     b. Run `terraform plan` to preview changes
     c. Apply infrastructure (create test repo + SPN)
     d. Verify repository exists via GitHub API call
     e. Check branch protection rules applied
     f. Confirm secret scanning enabled
     g. (If Azure) Verify SPN exists and secrets injected
     h. Run authentication test: GitHub Actions job uses injected secrets to authenticate to Azure
     i. Cleanup: Destroy test repository and SPN
   - Success criteria: All resources created, verified, and cleaned up without errors

3. **Manual Validation** (documented in test script):
   - Deploy one of the example projects (agents-playground, finvibe, security_agent)
   - Verify in GitHub UI: repository exists, branch protection active, secret scanning on
   - Verify in Azure Portal: SPN created, OIDC federation configured
   - Verify in GitHub Actions: test auth job succeeds using injected secrets

4. **Idempotency Test**:
   - Apply same configuration twice
   - Verify Terraform plan shows no changes on second apply
   - Verify no duplicate repositories or PRs created

---

### Phase 3: Bootstrap Workflow Integration

**Purpose**: Ensure CodeQL and deployment workflows are bootstrapped idempotently

**Steps** (*if gap analysis reveals needed work*):

1. Review `.github/workflows/bootstrap-workflows.yml` for idempotency logic
2. Confirm it compares existing workflow files with templates before creating PRs
3. Validate it handles the `update_branch` configuration option
4. Add tests to verify:
   - First run: Bootstrap branches and PRs created
   - Second run (no changes): No new branches/PRs created
   - Config change: Update PR created with new content

---

### Phase 4: Documentation & Polish

**Purpose**: Complete all documentation and create implementation checklists

**Steps**:

1. Finalize all markdown documents created in Phase 1
2. Add code examples and real YAML configurations
3. Create a `CONTRIBUTING.md` section on adding new projects
4. Update main `README.md` with architecture reference to `.specify/memory/constitution.md`
5. Add governance notes on updating the vending machine itself (must follow PR-gated process)

---

## Relevant Files

- [modules/repository/main.tf](modules/repository/main.tf) — GitHub resource provisioning (validation point for FR-001 through FR-005, FR-009)
- [modules/entra-spn/main.tf](modules/entra-spn/main.tf) — Azure SPN and OIDC setup (validation point for FR-006)
- [projects/main.tf](projects/main.tf) — Module composition and auto-discovery (validation point for overall orchestration)
- [projects/terraform.tfvars](projects/terraform.tfvars) — Shared variables (subscription ID, tenant, etc.)
- [.github/workflows/bootstrap-workflows.yml](.github/workflows/bootstrap-workflows.yml) — Workflow bootstrapping (validation point for FR-008 integration)
- [docs/workflow-bootstrapping.md](docs/workflow-bootstrapping.md) — Existing documentation on workflow bootstrapping

---

## Verification

### Automated Verification

1. **Terraform Plan Validation** (runs on every PR)
   - Command: `terraform -chdir=projects plan -out=plan.tfplan`
   - Success: Plan shows expected resources without errors
   - Failure: Abort merge if plan fails

2. **Integration Test Workflow** (Phase 2)
   - Command: `.github/workflows/test-vending-workflow.yml`
   - Creates temporary test repo and verifies all user stories
   - Cleans up resources post-test
   - Must pass before merge

### Manual Verification

1. **Example Project Deployment**
   - Deploy agents-playground or finvibe via Terraform apply
   - Verify in GitHub: repo exists with correct settings
   - Verify in Azure: SPN created (if deploy_to_azure: true)
   - Verify secrets injected: GitHub Actions can authenticate

2. **Idempotency Check**
   - Apply same config twice
   - Second apply should show `No changes` in Terraform plan

3. **End-to-End Scenario**
   - Create new project YAML in projects/configs/my-test.yaml
   - Commit and push to main
   - Watch GitHub Actions run vending workflow
   - Confirm new repository appears in GitHub
   - Verify all settings (branch protection, secret scanning, etc.)

---

## Decisions

1. **Terraform State**: Assumed to be managed by Azure Storage Account backend (as referenced in variables); verification step confirms this is configured in `projects/providers.tf`.

2. **Scope Boundaries**:
   - ✅ **INCLUDED**: Repository provisioning, branch protection, secret scanning, GitHub Advanced Security defaults, Azure SPN + OIDC, secrets injection, workflow bootstrapping
   - ❌ **EXCLUDED**: Repository content initialization (initial files, README generation), team/permission management beyond default role, custom workflow templates (reuses existing templates)

3. **Rollback Strategy**: If repository is created but Azure SPN fails, current behavior is to apply partial Terraform state. Future enhancement: implement Terraform state filtering or separate projects for better rollback isolation.

4. **Idempotency**: Workflow bootstrapping uses GitHub Actions (not Terraform) with content comparison logic to avoid branch/PR churn. This is documented in `docs/workflow-bootstrapping.md` and must be integrated with PR-gated update mechanism.

---

## Further Considerations

1. **CodeQL Workflow Bootstrapping** — The specification requires FR-008 (CodeQL workflow bootstrapping), but the Terraform modules don't directly manage this. The `.github/workflows/bootstrap-workflows.yml` GitHub Actions workflow is responsible. **Clarification needed**: Is this workflow currently running and successfully bootstrapping CodeQL into vended repositories? Recommend confirming in Phase 0 gap analysis.

2. **Update Branch Mechanism** — Specification mentions `update_branch` for proposing changes via PR when branch protection is enabled. **Clarification needed**: Should the Terraform root module create this branch, or is it created by the bootstrap workflow? Current code has the field in examples but no explicit TF resource for it. Recommend clarifying ownership in Phase 0.

3. **Repository Naming Validation** — The specification assumes project naming follows GitHub conventions, but no explicit validation is enforced in Terraform. **Recommendation**: Add a `locals` block with validation logic to reject invalid names early (regex check for alphanumeric + hyphens, no spaces or special chars).

---

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Two provider blocks (github + azuread + azurerm) | Provisioning spans GitHub and Azure; each requires distinct authentication and API | Single-provider approach would require manual SPN creation outside Terraform, breaking infrastructure-as-code principle |
| Conditional module invocation (only create SPN for deploy_to_azure: true) | Azure integration is optional per customer need; avoids unnecessary cost and cloud identity overhead | Always-on approach wastes resources for non-Azure projects and violates least-privilege principle |

---

## Summary

**Implementation Status**: ✅ **75% complete** — Core Terraform modules and root orchestration already exist. Work is primarily **validation, integration testing, and documentation**.

**Remaining Work**:
1. Phase 0: Validate gap analysis for FR-008 (CodeQL bootstrapping) and FR-010 (update branch mechanism)
2. Phase 1: Create architecture, schema, quickstart, and troubleshooting documentation
3. Phase 2: Build integration tests and manual verification procedures
4. Phase 4: Polish documentation and finalize

**Timeline**: Assuming existing code is stable, remaining work is 4-6 weeks for a comprehensive, well-tested, well-documented release.

**Risk**: Workflow bootstrapping (CodeQL, deploy workflows) integration unclear—recommend clarifying with Phase 0 analysis before proceeding.
