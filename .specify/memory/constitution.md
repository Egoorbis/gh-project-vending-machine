<!--
Sync Impact Report
- Version change: template -> 1.0.0
- Modified principles:
	- [PRINCIPLE_1_NAME] -> I. Terraform-First, Declarative Infrastructure
	- [PRINCIPLE_2_NAME] -> II. Security-By-Default and Least Privilege
	- [PRINCIPLE_3_NAME] -> III. Idempotent and Drift-Resistant Automation
	- [PRINCIPLE_4_NAME] -> IV. Pull-Request-Gated Change Flow
	- [PRINCIPLE_5_NAME] -> V. Verifiable Delivery and Traceability
- Added sections:
	- Security and Platform Constraints
	- Workflow and Quality Gates
- Removed sections:
	- None
- Templates requiring updates:
	- ✅ .specify/templates/plan-template.md
	- ✅ .specify/templates/spec-template.md
	- ✅ .specify/templates/tasks-template.md
	- ⚠ pending (path not present): .specify/templates/commands/*.md
	- ✅ README.md
- Follow-up TODOs:
	- None
-->

# GitHub Repository Vending Machine Constitution

## Core Principles

### I. Terraform-First, Declarative Infrastructure
All platform and repository provisioning changes MUST be expressed in Terraform and
committed as reviewable code. Manual, out-of-band configuration is prohibited except
for emergency mitigation, and any emergency change MUST be codified in Terraform
within the next merge cycle. Rationale: declarative infrastructure is the project's
source of truth and is required for repeatability and auditability.

### II. Security-By-Default and Least Privilege
Every vended repository and cloud identity MUST default to secure settings: branch
protection enabled unless explicitly waived, secret scanning and vulnerability alerts
enabled, and OIDC-based keyless authentication preferred over static credentials.
Role assignments MUST be scoped to the minimum required permissions. Rationale:
the system exists to standardize secure delivery, so insecure defaults are defects.

### III. Idempotent and Drift-Resistant Automation
Automation MUST be safe to run repeatedly with no unintended side effects. Changes
to branch/PR bootstrapping, workflow generation, and repository settings MUST avoid
re-creating ephemeral artifacts when no content change exists. Rationale: idempotent
delivery pipelines reduce operational noise and prevent configuration churn.

### IV. Pull-Request-Gated Change Flow
When branch protection is enabled, delivery to default branches MUST occur through
pull requests with reviewable diffs. Update branches for bootstrapped repositories
MUST be deterministic and reused consistently for review workflows. Rationale:
PR gates provide human and automated policy checkpoints before production impact.

### V. Verifiable Delivery and Traceability
Each change MUST include verifiable evidence prior to merge: at minimum formatting,
validation, and plan/apply safety checks for infrastructure changes, plus workflow
or content-diff checks for bootstrapped artifacts. Repository and deployment changes
MUST be traceable to configuration inputs under projects/configs. Rationale:
verification and traceability are required for trustworthy multi-repo automation.

## Security and Platform Constraints

- Terraform modules under modules/ and roots under projects/ are the authoritative
	implementation locations for infrastructure behavior.
- Project configuration files under projects/configs/ MUST remain schema-consistent
	and explicit about security-relevant toggles such as enable_branch_protection and
	deploy_to_azure.
- Generated or bootstrapped workflow files MUST originate from maintained templates
	and content comparison logic before proposing updates.
- Secrets MUST NOT be committed to source control; GitHub Actions integrations MUST
	use injected secrets or OIDC flows with least privilege.

## Workflow and Quality Gates

1. Define desired behavior through configuration or Terraform diff before
	implementation.
2. Run validation gates locally or in CI (format, validate, and policy/security
	checks appropriate to changed assets).
3. For workflow bootstrapping changes, verify idempotent behavior by confirming no
	PR/branch churn when templates and target files are already equivalent.
4. Use pull requests for protected branches and include concise evidence of checks
	in the PR description.
5. Merge only when governance checks pass and no unresolved security regressions
	remain.

## Governance

This constitution supersedes informal team habits for this repository's delivery
process. Amendments MUST be proposed via pull request with:
- a clear rationale,
- impact assessment on templates, workflows, and documentation,
- and a migration note for any behavior-changing update.

Versioning policy (semantic versioning):
- MAJOR: backward-incompatible governance changes or principle removals/redefinitions.
- MINOR: new principle/section or materially expanded mandatory guidance.
- PATCH: clarifications, wording improvements, and non-semantic refinements.

Compliance review expectations:
- Every implementation plan MUST include a constitution check.
- Every specification and task set MUST reflect applicable security and verification
	gates from this document.
- Reviewers MUST block merges that violate non-negotiable principles above.

**Version**: 1.0.0 | **Ratified**: 2026-05-15 | **Last Amended**: 2026-05-15
