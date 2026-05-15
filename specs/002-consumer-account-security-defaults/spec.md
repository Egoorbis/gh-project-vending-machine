# Feature Specification: Consumer Account Security Defaults

**Feature Branch**: `002-consumer-account-security-defaults`

**Created**: 2026-05-15

**Status**: Draft

**Input**: User description: "we build this vending machine for a consumer github account. hence make sure no organisation related features such as push rules are used. additionally make sure that codeql scanning is using default setup, that dependabot malware alerts, security updates and grouped security updates are enabled by default"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Provision a Secure Repository on a Personal Account (Priority: P1)

A developer with a personal GitHub account uses the vending machine to provision a new repository. Without any extra configuration, the resulting repository has CodeQL scanning active (using GitHub's automated default setup), Dependabot vulnerability alerts enabled, Dependabot security update pull requests enabled, and grouped security updates enabled. The repository provisions cleanly without any API errors related to unsupported account-level features.

**Why this priority**: This is the core value proposition — a new repository that is secure by default on a personal account, with zero manual post-provisioning steps. All other stories depend on this working.

**Independent Test**: Run the vending machine against a config with no security overrides pointing to a personal GitHub account. Verify the repository exists, CodeQL default setup is active, and Dependabot alerts/updates are on.

**Acceptance Scenarios**:

1. **Given** a config file with no explicit security toggles, **When** the vending machine applies the configuration, **Then** the resulting repository has CodeQL default setup active, Dependabot alerts enabled, Dependabot security updates enabled, and Dependabot grouped security updates enabled.
2. **Given** a personal GitHub account (not an organisation), **When** the vending machine applies, **Then** no push ruleset is created and no API error related to org-only features is raised.
3. **Given** a previously provisioned repository, **When** the vending machine is re-applied without changes, **Then** no drift is detected and no resources are modified.

---

### User Story 2 - Opt Out of Specific Security Features (Priority: P2)

A developer has a repository whose toolchain conflicts with CodeQL default setup (e.g., an unsupported language). They set `enable_codeql_default_setup: false` in their config and re-apply. Only the CodeQL feature is disabled; Dependabot alerts and updates remain active.

**Why this priority**: Teams must be able to escape-hatch individual security features without losing all defaults. Independent from P1 provisioning success.

**Independent Test**: Apply a config with `enable_codeql_default_setup: false` and verify CodeQL is not configured while Dependabot settings remain unchanged.

**Acceptance Scenarios**:

1. **Given** a config with `enable_codeql_default_setup: false`, **When** the vending machine applies, **Then** CodeQL default setup is not enabled on the repository.
2. **Given** a config with `enable_dependabot_security_updates: false`, **When** the vending machine applies, **Then** security update PRs are not enabled, but vulnerability alerts remain active.
3. **Given** any combination of security feature toggles, **When** the vending machine applies, **Then** only the explicitly disabled features are absent; all other defaults remain active.

---

### User Story 3 - Push Ruleset Config Is Rejected or Silently Ignored (Priority: P3)

A developer copies an old config that contained `enable_push_ruleset: true`. When they apply it against a personal account repo, the vending machine either rejects the config with a clear validation message at plan time or silently treats it as a no-op — in either case, no API call to create a push ruleset is made.

**Why this priority**: Prevents hard-to-diagnose runtime 422 errors. Builds confidence that the tool is personal-account-safe by default.

**Independent Test**: Apply a config with `enable_push_ruleset: true` against a personal account repo and confirm no push ruleset resource is attempted and no API error occurs.

**Acceptance Scenarios**:

1. **Given** `enable_push_ruleset: true` in a config for a personal-account repository, **When** the vending machine runs, **Then** no push ruleset is created and no 422 error is raised.
2. **Given** a new config with no push ruleset field, **When** the vending machine applies, **Then** no push ruleset is attempted by default.

---

### Edge Cases

- What happens when the GitHub API rate-limits Dependabot enablement calls during a large batch of repository provisioning?
- How does the system handle a repository that had CodeQL custom setup previously — does switching to default setup conflict?
- What happens if a config explicitly sets all security features to `false` — does the system warn the operator?
- How does idempotency behave if Dependabot grouped updates were enabled in a previous apply and the config hasn't changed?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The vending machine MUST NOT create or attempt to create push rulesets on any vended repository, as this feature is exclusive to organisation-owned repositories.
- **FR-002**: CodeQL scanning MUST be enabled by default on all vended repositories using GitHub's automated default setup (not a custom workflow file).
- **FR-003**: Dependabot vulnerability (malware) alerts MUST be enabled by default on all vended repositories.
- **FR-004**: Dependabot security update pull requests MUST be enabled by default on all vended repositories.
- **FR-005**: Dependabot grouped security updates MUST be enabled by default on all vended repositories, consolidating related update PRs to reduce noise.
- **FR-006**: Each of the four security features (CodeQL default setup, Dependabot alerts, security updates, grouped updates) MUST be individually toggle-able via the repository config file, defaulting to `true`.
- **FR-007**: The configuration schema documentation MUST describe each security toggle field, its default value, and the behaviour when disabled.
- **FR-008**: When all security toggles use their defaults, re-applying the vending machine against an existing repository MUST produce no changes (idempotent behaviour).
- **FR-009**: The example configuration files shipped with the vending machine MUST reflect the correct defaults and MUST NOT include any org-only configuration fields set to `true`.

### Constitution Alignment *(mandatory)*

- **Terraform-first delivery**: All security feature enablement that can be managed via the GitHub Terraform provider is declared as Terraform resources. Any feature not yet supported by the provider is clearly documented as an out-of-band step or deferred to a future provider version.
- **Security-by-default**: All four security toggles default to enabled. A new repository vended without any explicit security config is more secure than one provisioned manually without thinking about defaults.
- **Idempotency**: Each security resource is declared such that repeated applies do not trigger changes when nothing has changed in the config or on the GitHub side.
- **PR-gated flow**: Changes to security defaults flow through the existing PR-gated `vend-project.yml` workflow; no separate pipeline is required.
- **Verifiable delivery**: The presence and state of each security feature is observable via the GitHub repository settings UI and GitHub API, providing clear post-apply verification steps without requiring specialised tooling.

### Key Entities *(include if feature involves data)*

- **Repository Config (YAML)**: Extended with `enable_codeql_default_setup`, `enable_dependabot_alerts`, `enable_dependabot_security_updates`, `enable_dependabot_grouped_updates` boolean fields, all defaulting to `true`.
- **Vended Repository**: A GitHub repository owned by a personal account with the above security features configured at provision time.
- **CodeQL Default Setup**: GitHub's built-in automated code scanning configuration — requires no workflow file; managed via the repository's code security settings.
- **Dependabot Alert**: A notification raised when a dependency with a known vulnerability (including malware) is detected.
- **Dependabot Security Update**: An automatically opened pull request that bumps a vulnerable dependency to a safe version.
- **Dependabot Grouped Update**: A Dependabot behaviour that batches multiple related security update PRs into a single PR to reduce review overhead.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A repository provisioned with default config has all four security features active within 60 seconds of the Terraform apply completing, with no manual post-provisioning steps required.
- **SC-002**: Re-applying an unchanged config against an existing repository produces zero planned changes across all security-related resources.
- **SC-003**: Zero API 422 errors related to organisation-only features occur when the vending machine is run against any personal-account repository.
- **SC-004**: All three example configuration files in the repository ship with `enable_push_ruleset` absent or `false`, and all four security toggles either absent (defaulting to `true`) or explicitly `true`.
- **SC-005**: The configuration schema documentation covers all new toggle fields with default values and disable-behaviour descriptions before the feature is considered complete.

## Assumptions

- The vending machine exclusively targets personal (consumer) GitHub accounts; organisation-level features are explicitly out of scope.
- GitHub's "CodeQL default setup" is available on all public repositories on personal accounts at no cost; private repositories on a free personal account may not support it.
- Dependabot grouped security updates are a repository-level setting available on personal accounts without requiring GitHub Advanced Security.
- The `integrations/github` Terraform provider (current version ~>6.x) may not expose all Dependabot settings as first-class resources; implementation will document any gap and use the best available mechanism (provider resource, `github_repository_file`-driven config, or post-apply script) without compromising the declared defaults.
- Push ruleset support is removed entirely from the module; no opt-in path is provided in this iteration, as the target environment is personal accounts only.
- Secret scanning and push protection (already in the module) are retained as-is — they work on personal-account public repos.
