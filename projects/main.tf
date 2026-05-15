locals {
  project_files = fileset("${path.module}/configs", "*.yaml")
  projects = {
    for f in local.project_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${path.module}/configs/${f}"))
  }
  project_validation = {
    for key, value in local.projects :
    key => {
      has_repo_name    = try(length(trimspace(tostring(value.repo_name))) > 0, false)
      has_description  = try(length(trimspace(tostring(value.description))) > 0, false)
      topics_is_list   = try(can([for t in value.additional_topics : tostring(t)]), true)
      update_is_string = try(value.update_branch == null || can(tostring(value.update_branch)), true)
      deploy_is_bool   = try(can(tobool(value.deploy_to_azure)), true)
    }
  }
  invalid_projects = [
    for key, checks in local.project_validation :
    key
    if !(checks.has_repo_name && checks.has_description && checks.topics_is_list && checks.update_is_string && checks.deploy_is_bool)
  ]
  azure_projects = {
    for key, value in local.projects :
    key => value
    if lookup(value, "deploy_to_azure", true)
  }
}

# 1. Vend the Identities (only for Azure-enabled projects)
module "spn" {
  source   = "../modules/entra-spn"
  for_each = local.azure_projects

  repo_name             = each.value.repo_name
  github_owner          = var.github_owner
  azure_subscription_id = var.azure_subscription_id
}

# 2. Vend the Repositories
module "repo" {
  source   = "../modules/repository"
  for_each = local.projects

  repo_name   = each.value.repo_name
  description = each.value.description

  additional_topics        = lookup(each.value, "additional_topics", [])
  enable_branch_protection = lookup(each.value, "enable_branch_protection", true)
  enable_push_ruleset      = lookup(each.value, "enable_push_ruleset", false)
  deploy_to_azure          = lookup(each.value, "deploy_to_azure", true)
  update_branch            = lookup(each.value, "update_branch", null)

  enable_code_scanning_gate = lookup(each.value, "enable_code_scanning_gate", false)

  azure_client_id         = try(module.spn[each.key].azure_client_id, "")
  azure_subscription_id   = var.azure_subscription_id
  azure_tenant_id         = var.azure_tenant_id
  backend_resource_group  = var.backend_resource_group
  backend_storage_account = var.backend_storage_account
  backend_container       = var.backend_container
}

# Fail early if any project config misses required fields or has invalid shape.
resource "terraform_data" "validate_projects" {
  input = local.project_validation

  lifecycle {
    precondition {
      condition     = length(local.invalid_projects) == 0
      error_message = "Invalid project config(s): ${join(", ", local.invalid_projects)}. Each config must include non-empty repo_name and description; additional_topics must be a list; update_branch must be string or null; deploy_to_azure must be boolean when provided."
    }
  }
}

# 3. Protect the vending machine's own repository
# Requires the "Terraform Action" CI job to pass before any PR can merge.
resource "github_repository_ruleset" "vending_machine_main" {
  name        = "protect-main"
  repository  = "gh-project-vending-machine"
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
    deletion         = true
    non_fast_forward = true

    pull_request {
      allowed_merge_methods             = ["squash"]
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
      required_approving_review_count   = 0
    }

    required_status_checks {
      # "Terraform Action" is the job name defined in vend-project.yml.
      # The plan step (id: plan) runs inside this job — if the plan fails,
      # the whole job fails and this check blocks the merge.
      required_check {
        context = "Terraform Action"
      }
      strict_required_status_checks_policy = true
    }
  }
}