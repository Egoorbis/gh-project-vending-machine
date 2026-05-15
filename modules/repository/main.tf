resource "github_repository" "this" {
  name        = var.repo_name
  description = var.description
  visibility  = "public"
  auto_init   = true

  delete_branch_on_merge = true
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  has_discussions        = false

  # Keep topics deterministic and duplicate-free to avoid update churn across re-applies.
  topics = sort(distinct(concat(["it-professional", "automation"], var.additional_topics)))

  allow_rebase_merge = false
  allow_squash_merge = true

  # Security Features (advanced_security omitted — always enabled on public repos)
  security_and_analysis {
    secret_scanning { status = "enabled" }
    secret_scanning_push_protection { status = "enabled" }
  }
}

resource "github_repository_ruleset" "main_branch" {
  count       = var.enable_branch_protection ? 1 : 0
  name        = "protect-main"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  rules {
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true

    pull_request {
      allowed_merge_methods             = ["squash"]
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
      required_approving_review_count   = 0
    }

    dynamic "required_code_scanning" {
      for_each = var.enable_code_scanning_gate ? [1] : []
      content {
        required_code_scanning_tool {
          alerts_threshold          = "errors"
          security_alerts_threshold = "high_or_higher"
          tool                      = "CodeQL"
        }
      }
    }
  }

  depends_on = [github_repository.this]
}

resource "github_actions_secret" "azure_secrets" {
  for_each = var.deploy_to_azure ? {
    "AZURE_CLIENT_ID"         = var.azure_client_id
    "AZURE_SUBSCRIPTION_ID"   = var.azure_subscription_id
    "AZURE_TENANT_ID"         = var.azure_tenant_id
    "BACKEND_RESOURCE_GROUP"  = var.backend_resource_group
    "BACKEND_STORAGE_ACCOUNT" = var.backend_storage_account
    "BACKEND_CONTAINER_NAME"  = var.backend_container
    "BACKEND_KEY"             = "${github_repository.this.name}.tfstate"
  } : {}

  repository  = github_repository.this.name
  secret_name = each.key
  # Provider integrations/github 6.11.1 expects plaintext_value here.
  plaintext_value = each.value

}

# Guard against partial Azure configuration when Azure integration is enabled.
resource "terraform_data" "validate_azure_secret_inputs" {
  input = {
    deploy_to_azure = var.deploy_to_azure
    values = {
      azure_client_id         = var.azure_client_id
      azure_subscription_id   = var.azure_subscription_id
      azure_tenant_id         = var.azure_tenant_id
      backend_resource_group  = var.backend_resource_group
      backend_storage_account = var.backend_storage_account
      backend_container       = var.backend_container
    }
  }

  lifecycle {
    precondition {
      condition = !var.deploy_to_azure || alltrue([
        for v in [
          var.azure_client_id,
          var.azure_subscription_id,
          var.azure_tenant_id,
          var.backend_resource_group,
          var.backend_storage_account,
          var.backend_container
        ] : length(trimspace(v)) > 0
      ])
      error_message = "deploy_to_azure is true, but one or more required Azure inputs are empty."
    }
  }
}

# This vending machine targets personal (consumer) GitHub accounts only.
# Push rulesets are org-only and must not be requested.
resource "terraform_data" "validate_personal_account_constraints" {
  input = {
    repo_name           = var.repo_name
    enable_push_ruleset = var.enable_push_ruleset
  }

  lifecycle {
    precondition {
      condition     = !var.enable_push_ruleset
      error_message = "enable_push_ruleset is not supported for personal-account repositories. Remove it or set it to false for ${var.repo_name}."
    }
  }
}

# NOTE: github_repository_dependabot_security_updates is omitted.
# Provider integrations/github ~>6.0 does not expose a resource or argument to
# enable vulnerability alerts (Dependabot alerts) declaratively. The API rejects
# enabling security updates until vulnerability alerts are active.
# This repository solves that gap in bootstrap-workflows.yml by calling GitHub
# APIs to reconcile vulnerability alerts and automated security fixes.

