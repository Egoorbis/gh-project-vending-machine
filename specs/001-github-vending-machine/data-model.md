# Data Model: GitHub Repository Vending Machine

## Entity: ProjectConfig
- Description: YAML configuration unit loaded from `projects/configs/*.yaml`.
- Fields:
  - `repo_name` (string, required, non-empty)
  - `description` (string, required, non-empty)
  - `additional_topics` (list(string), optional, default `[]`)
  - `enable_branch_protection` (bool, optional, default `true`)
  - `deploy_to_azure` (bool, optional, default `true`)
  - `update_branch` (string|null, optional)
  - `enable_push_ruleset` (bool, optional)
  - `enable_code_scanning_gate` (bool, optional)
- Validation rules:
  - Missing optional fields resolve to defaults.
  - `deploy_to_azure` must be boolean when provided.
  - `update_branch` must be string or null.

## Entity: VendedRepository
- Description: GitHub repository provisioned via module `modules/repository`.
- Fields:
  - `name`
  - `description`
  - `topics`
  - `branch_protection_enabled`
  - `security_scanning_enabled`
  - `dependabot_updates_enabled`

## Entity: AzureIdentity
- Description: Entra app/SPN resources provisioned via `modules/entra-spn` when `deploy_to_azure=true`.
- Fields:
  - `azure_client_id`
  - `service_principal_object_id`
  - `application_object_id`
  - `oidc_subject_main`
  - `oidc_subject_pull_request`

## Entity: RepositorySecretSet
- Description: GitHub Actions secrets bound to repository for Azure deployment.
- Fields:
  - `AZURE_CLIENT_ID`
  - `AZURE_SUBSCRIPTION_ID`
  - `AZURE_TENANT_ID`
  - `BACKEND_RESOURCE_GROUP`
  - `BACKEND_STORAGE_ACCOUNT`
  - `BACKEND_CONTAINER_NAME`
  - `BACKEND_KEY`
- Constraint:
  - All values must be non-empty when `deploy_to_azure=true`.

## Relationships
- `ProjectConfig` 1:1 `VendedRepository`
- `ProjectConfig` 0:1 `AzureIdentity` (conditional on `deploy_to_azure`)
- `VendedRepository` 0:1 `RepositorySecretSet` (conditional on `deploy_to_azure`)

## State Transitions
1. `ProjectConfig` added/updated
2. Validation pass/fail
3. Repository provision/update
4. Conditional Azure identity provision
5. Conditional secret injection
6. Verification via outputs and Terraform validation
