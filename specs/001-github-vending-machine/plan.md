# Implementation Plan: GitHub Repository Vending Machine

**Branch**: `001-github-vending-machine` | **Date**: 2026-05-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-github-vending-machine/spec.md`

## Summary

Continue phased implementation with explicit compatibility remediation so Terraform validates end-to-end in the current repo provider set. This update specifically includes:

- Remove/replace `github_repository_vulnerability_alerts` with a provider-supported approach.
- Ensure deprecation guidance is handled without introducing unsupported arguments for the pinned provider.

Primary approach: keep security defaults enforced via supported resources and blocks, preserve idempotency checks, and harden configuration validation/traceability outputs.

## Technical Context

**Language/Version**: Terraform (HCL), provider lock currently at `integrations/github` `6.11.1`

**Primary Dependencies**:
- `integrations/github` provider (`~> 6.0`)
- `hashicorp/azuread`
- `hashicorp/azurerm`

**Storage**: Terraform state (Azure backend)

**Testing**:
- `terraform fmt`
- `terraform validate` (from `projects/`)
- CI workflows under `.github/workflows/`

**Target Platform**: GitHub Actions + Terraform CLI

**Project Type**: Terraform multi-module infrastructure automation

**Performance Goals**: Idempotent re-runs with no drift; validation passes before merge

**Constraints**:
- Must be compatible with current provider lockfile and schema
- No unsupported resources/arguments in active provider version
- Security defaults must remain enforced

**Scale/Scope**: Multiple repository configs under `projects/configs/` (current + new)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Terraform-first impact identified: all changes map to `modules/`, `projects/`, and workflows.
- [x] Security defaults preserved or explicitly justified.
- [x] Idempotency impact reviewed and preserved.
- [x] PR-gated delivery path remains in place.
- [x] Verification evidence planned: fmt + validate + CI checks.
- [x] Traceability maintained via config keys and outputs.

## Phase 0: Research Outcomes

See [research.md](research.md). Key decisions finalized:

1. Remove unsupported `github_repository_vulnerability_alerts` resource.
2. Follow provider-supported argument schema for secret values in the pinned provider.
3. Keep default-aware validation (`lookup(..., true)`) for backward-compatible config checks.

## Phase 1: Design Outputs

Generated artifacts:

- [data-model.md](data-model.md)
- [contracts/project-config-contract.md](contracts/project-config-contract.md)
- [quickstart.md](quickstart.md)

Post-design constitution check:

- [x] Security-by-default still modeled through supported capabilities.
- [x] Validation-first workflow documented and reproducible.
- [x] No unresolved clarifications remain for requested plan update.

## Project Structure

### Documentation (this feature)

```text
specs/001-github-vending-machine/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── project-config-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
modules/
├── repository/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── entra-spn/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf

projects/
├── main.tf
├── variables.tf
├── outputs.tf
└── configs/

.github/workflows/
├── vend-project.yml
└── bootstrap-workflows.yml
```

**Structure Decision**: Keep current Terraform module structure; apply compatibility and validation fixes in place rather than introducing new modules.

## Planned Remediation Slice (this update)

1. Replace unsupported vulnerability alerts resource with provider-supported security approach.
2. Remove deprecation guidance noise by aligning argument usage to the pinned provider schema.
3. Re-run `terraform validate` to confirm end-to-end pass in current repo version.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Provider-specific compatibility handling | Lockfile/provider schema differ from generic guidance | Generic replacement (`value`) breaks current provider validation |
