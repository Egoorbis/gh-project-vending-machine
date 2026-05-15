# Tasks: GitHub Repository Vending Machine

**Input**: Design documents from `/specs/001-github-vending-machine/`

**Prerequisites**: plan.md (required), spec.md (required for user stories)

**Tests/Verification**: Feature-level tests were not explicitly requested, but constitution-required verification tasks are included (Terraform validation, CI checks, idempotency verification).

**Organization**: Tasks are grouped by user story to enable independent implementation and validation of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Every task includes an exact file path

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish documentation and baseline project artifacts used across all stories.

- [x] T001 Create feature quickstart scaffold in specs/001-github-vending-machine/quickstart.md
- [x] T002 [P] Create architecture document scaffold in docs/vending-machine-architecture.md
- [x] T003 [P] Create project config schema document scaffold in docs/project-config-schema.md
- [x] T004 [P] Create troubleshooting document scaffold in docs/troubleshooting.md
- [x] T005 Normalize Terraform formatting targets in modules/repository/main.tf and modules/entra-spn/main.tf and projects/main.tf

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add core validation and wiring that all user stories depend on.

**⚠️ CRITICAL**: No user story work should start until this phase is complete.

- [x] T006 Add project configuration validation locals in projects/main.tf
- [x] T007 Add variable-level validation constraints in projects/variables.tf
- [x] T008 Add update-branch plumbing variables in modules/repository/variables.tf and projects/main.tf
- [x] T009 Add traceability outputs for provisioned repositories in modules/repository/outputs.tf and projects/outputs.tf
- [x] T010 Add shared defaults and schema notes in projects/examples/README.md

**Checkpoint**: Foundation complete; user stories can now be implemented independently.

---

## Phase 3: User Story 1 - Deploy New GitHub Repository (Priority: P1) 🎯 MVP

**Goal**: Provision repositories from YAML config with secure baseline settings and idempotent behavior.

**Independent Test**: Add a YAML config in `projects/configs/`, run vending workflow, and confirm repository is created/updated without duplication and with expected metadata.

### Implementation for User Story 1

- [ ] T011 [US1] Ensure repository create/update behavior is idempotent in modules/repository/main.tf
- [ ] T012 [P] [US1] Ensure branch protection defaults and ruleset behavior in modules/repository/main.tf
- [ ] T013 [P] [US1] Ensure repository topic merge behavior from config in modules/repository/main.tf
- [x] T014 [US1] Add P1 example config for repository provisioning in projects/configs/us1-repo-provisioning.yaml
- [x] T015 [US1] Document repository provisioning MVP flow in docs/quickstart.md

**Checkpoint**: User Story 1 is independently functional and MVP-ready.

---

## Phase 4: User Story 2 - Manage Repository Secrets and Credentials (Priority: P2)

**Goal**: Provision Azure identities and inject required GitHub Actions secrets only when Azure deployment is enabled.

**Independent Test**: Use `deploy_to_azure: true` config and verify SPN, OIDC credentials, and GitHub Actions secrets are created; confirm `deploy_to_azure: false` skips them.

### Implementation for User Story 2

- [x] T016 [US2] Ensure Azure-project filtering and module wiring in projects/main.tf
- [x] T017 [US2] Ensure OIDC federation credentials for main and PR flows in modules/entra-spn/main.tf
- [x] T018 [US2] Ensure Azure GitHub Actions secret injection mapping in modules/repository/main.tf
- [x] T019 [P] [US2] Expose identity and repository outputs for verification in modules/entra-spn/outputs.tf and modules/repository/outputs.tf
- [x] T020 [US2] Add Azure-enabled example config in projects/configs/us2-azure-enabled.yaml

**Checkpoint**: User Story 2 works independently with secure credential provisioning.

---

## Phase 5: User Story 3 - Configure GitHub Advanced Security (Priority: P2)

**Goal**: Enforce security defaults and bootstrap workflow-based code scanning configuration.

**Independent Test**: Vend a repository and verify secret scanning, push protection, vulnerability/security settings, and CodeQL workflow bootstrap behavior.

### Implementation for User Story 3

- [ ] T021 [US3] Ensure secret scanning and push protection defaults in modules/repository/main.tf
- [ ] T022 [US3] Ensure code scanning gate configuration wiring in modules/repository/variables.tf and projects/main.tf
- [ ] T023 [US3] Implement idempotent workflow bootstrap logic for CodeQL and deploy workflows in .github/workflows/bootstrap-workflows.yml
- [ ] T024 [P] [US3] Align workflow templates used for bootstrap in modules/repository/templates/codeql.yaml.tftpl and modules/repository/templates/tf_action.yaml.tftpl
- [ ] T025 [US3] Add security-defaults example config in projects/configs/us3-security-defaults.yaml

**Checkpoint**: User Story 3 is independently functional with security defaults enforced.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalize governance-aligned verification, docs, and cross-story hardening.

- [ ] T026 [P] Finalize architecture documentation in docs/vending-machine-architecture.md
- [ ] T027 [P] Finalize project configuration schema and examples in docs/project-config-schema.md
- [ ] T028 [P] Finalize troubleshooting paths for rate limits and partial failures in docs/troubleshooting.md
- [ ] T029 Add Terraform verification gate in .github/workflows/vend-project.yml
- [ ] T030 Add idempotency verification step for workflow bootstrap in .github/workflows/bootstrap-workflows.yml
- [ ] T031 Run and record quickstart validation in specs/001-github-vending-machine/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; starts immediately.
- **Foundational (Phase 2)**: Depends on Setup completion; blocks all stories.
- **User Stories (Phases 3-5)**: Depend on Foundational completion.
- **Polish (Phase 6)**: Depends on all targeted user stories being complete.

### User Story Dependencies

- **US1 (P1)**: Starts after Foundational; no dependency on US2/US3.
- **US2 (P2)**: Starts after Foundational; independent of US1 implementation details.
- **US3 (P2)**: Starts after Foundational; independent of US1/US2 implementation details.

### Within Each User Story

- Core infrastructure/resource logic before example config and documentation.
- Outputs and wiring before final validation notes.
- Story-specific checkpoint must pass before moving to cross-cutting polish.

---

## Parallel Opportunities

- Setup parallel tasks: `T002`, `T003`, `T004`
- Foundational parallelizable portions are embedded in multi-file wiring tasks after `T006`
- US1 parallel tasks: `T012`, `T013`
- US2 parallel tasks: `T019`
- US3 parallel tasks: `T024`
- Polish parallel tasks: `T026`, `T027`, `T028`

---

## Parallel Example: User Story 1

```bash
# Parallel lane A
T012 Ensure branch protection defaults and ruleset behavior in modules/repository/main.tf

# Parallel lane B
T013 Ensure repository topic merge behavior from config in modules/repository/main.tf
```

## Parallel Example: User Story 3

```bash
# Parallel lane A
T023 Implement idempotent workflow bootstrap logic in .github/workflows/bootstrap-workflows.yml

# Parallel lane B
T024 Align workflow templates in modules/repository/templates/codeql.yaml.tftpl and modules/repository/templates/tf_action.yaml.tftpl
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 (Setup)
2. Complete Phase 2 (Foundational)
3. Complete Phase 3 (US1)
4. Validate US1 independently as MVP before expanding scope

### Incremental Delivery

1. Deliver US1 (repository provisioning) as deployable MVP
2. Deliver US2 (identity + secrets) as secure integration increment
3. Deliver US3 (security defaults + bootstrap) as governance increment
4. Run final polish and verification gates

### Parallel Team Strategy

1. Team completes Setup + Foundational together
2. Then split by story:
   - Engineer A: US1
   - Engineer B: US2
   - Engineer C: US3
3. Converge in Phase 6 for cross-cutting verification and docs finalization

---

## Notes

- Tasks use strict checklist format with IDs `T001`-`T031`.
- Story labels appear only in user-story phases.
- File paths are explicit to keep tasks directly executable.
- Verification tasks satisfy constitution gates for Terraform-first, security-by-default, idempotency, PR-gated flow, and traceability.
