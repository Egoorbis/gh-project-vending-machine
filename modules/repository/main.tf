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

  topics = concat(["it-professional", "automation"], var.additional_topics)

  allow_rebase_merge = false
  allow_squash_merge = true

  # Security Features
  security_and_analysis {
    advanced_security {
      status = "enabled"
    }
    secret_scanning { status = "enabled" }
    secret_scanning_push_protection { status = "enabled" }
  }
}

locals {
  update_branch_name = coalesce(var.update_branch, "chore/vending-machine-bootstrap")
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

  depends_on = [github_repository_file.workflow, github_repository_file.codeql, github_repository_file.dependabot, github_repository_file.dependency_submission]
}

resource "github_repository_ruleset" "push_guard" {
  count       = var.enable_push_ruleset ? 1 : 0
  name        = "push-guard"
  repository  = github_repository.this.name
  target      = "push"
  enforcement = "active"

  rules {
    file_extension_restriction {
      restricted_file_extensions = ["*.pem", "*.pfx", "*.p12", "*.key", "*.env", "*.secret"]
    }

    max_file_size {
      max_file_size = 10
    }
  }
}

resource "github_branch" "update" {
  count      = var.create_bootstrap_pr ? 1 : 0
  repository = github_repository.this.name
  branch     = local.update_branch_name

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

  repository      = github_repository.this.name
  secret_name     = each.key
  plaintext_value = each.value

}

resource "github_repository_file" "workflow" {
  count               = var.deploy_to_azure ? 1 : 0
  repository          = github_repository.this.name
  branch              = local.update_branch_name
  file                = ".github/workflows/vending-machine/deploy.yml"
  content             = templatefile("${path.module}/templates/tf_action.yaml.tftpl", {})
  commit_message      = "chore: bootstrap caller workflow [skip ci]"
  overwrite_on_create = true

  depends_on = [github_branch.update]
}

resource "github_repository_file" "codeql" {
  repository          = github_repository.this.name
  branch              = local.update_branch_name
  file                = ".github/workflows/codeql.yml"
  content             = templatefile("${path.module}/templates/codeql.yaml.tftpl", {})
  commit_message      = "chore: bootstrap CodeQL analysis [skip ci]"
  overwrite_on_create = true

  depends_on = [github_branch.update]
}

resource "github_repository_file" "dependabot" {
  repository          = github_repository.this.name
  branch              = local.update_branch_name
  file                = ".github/dependabot.yml"
  content             = templatefile("${path.module}/templates/dependabot.yml.tftpl", {})
  commit_message      = "chore: configure Dependabot with grouped security updates [skip ci]"
  overwrite_on_create = true

  depends_on = [github_branch.update]
}

resource "github_repository_file" "dependency_submission" {
  repository          = github_repository.this.name
  branch              = local.update_branch_name
  file                = ".github/workflows/dependency-submission.yml"
  content             = templatefile("${path.module}/templates/dependency-submission.yaml.tftpl", {})
  commit_message      = "chore: add automatic dependency submission workflow [skip ci]"
  overwrite_on_create = true

  depends_on = [github_branch.update]
}

resource "github_repository_pull_request" "bootstrap_workflows" {
  count           = var.create_bootstrap_pr ? 1 : 0
  base_repository = github_repository.this.name
  base_ref        = "main"
  head_ref        = local.update_branch_name
  title           = "chore: bootstrap workflow files"
  body            = "Automated PR created by project vending to add or update bootstrap workflow files."

  depends_on = [github_repository_file.workflow, github_repository_file.codeql, github_repository_file.dependabot, github_repository_file.dependency_submission]
}

resource "github_repository_dependabot_security_updates" "this" {
  repository = github_repository.this.name
  enabled    = true
}

resource "github_repository_vulnerability_alerts" "this" {
  repository = github_repository.this.name
  enabled    = true
}

