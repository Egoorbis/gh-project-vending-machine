# Phase 0 Research: GitHub Repository Vending Machine

## Decision 1: Remove unsupported `github_repository_vulnerability_alerts`
- Decision: Remove the `github_repository_vulnerability_alerts` resource from `modules/repository/main.tf` and rely on provider-supported security controls (`security_and_analysis` block and `github_repository_dependabot_security_updates`).
- Rationale: The pinned provider (`integrations/github` 6.11.1 in `.terraform.lock.hcl`) does not support this resource type, causing `terraform validate` to fail end-to-end.
- Alternatives considered:
  - Upgrade provider and keep resource: rejected for now because current repo lock and compatibility expectations are anchored to `~> 6.0` behavior.
  - Keep resource behind condition/flag: rejected because validation still fails at schema load time.

## Decision 2: Handle deprecation guidance without breaking provider compatibility
- Decision: Treat provider schema compatibility as the source of truth for secret arguments in this repo version and keep `plaintext_value` until provider support for `value` is confirmed in lockfile/runtime.
- Rationale: Guidance suggesting `value` instead of `plaintext_value` conflicts with current provider schema in this environment and causes validation failure.
- Alternatives considered:
  - Force usage of `value`: rejected because it causes `Unsupported argument`.
  - Ignore mismatch and keep stale guidance unresolved: rejected; documented compatibility rule removes ambiguity for current implementation.

## Decision 3: Strengthen config validation with defaults-aware checks
- Decision: Validate `deploy_to_azure` using `lookup(value, "deploy_to_azure", true)` to treat omitted values as default true.
- Rationale: Existing configs omitted this field and were incorrectly flagged invalid by direct access checks.
- Alternatives considered:
  - Require `deploy_to_azure` in every config: rejected due to backward compatibility and unnecessary churn.

## Decision 4: Verification-first remediation
- Decision: Pair each compatibility change with `terraform fmt` and `terraform validate` gates in CI and local workflow.
- Rationale: Constitutional requirement for verifiable delivery and traceability.
- Alternatives considered:
  - Ad hoc manual verification only: rejected as non-repeatable.
