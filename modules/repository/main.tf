resource "github_repository" "this" {
  name        = var.repo_name
  description = var.description
  visibility  = "public"
  auto_init   = true

  delete_branch_on_merge = true
  has_issues   = true
  has_projects = false
  has_wiki     = false
  has_discussions = false

  topics = concat(["it-professional", "automation"], var.additional_topics)

  allow_rebase_merge = false
  allow_squash_merge = true

  # Security Features
  vulnerability_alerts = true
  security_and_analysis {
    secret_scanning { status = "enabled" }
    secret_scanning_push_protection { status = "enabled" }
  }
}

resource "github_branch_protection" "main" {
  repository_id    = github_repository.this.node_id
  pattern          = "main"
  enforce_admins   = true
  required_linear_history = true
  
  required_pull_request_reviews {
    required_approving_review_count = 0 
  }
}


resource "github_actions_secret" "azure_secrets" {
  for_each = {
    "AZURE_CLIENT_ID"       = var.azure_client_id
    "AZURE_SUBSCRIPTION_ID" = var.azure_subscription_id
    "AZURE_TENANT_ID"       = var.azure_tenant_id
    "BACKEND_RESOURCE_GROUP"  = var.backend_resource_group
    "BACKEND_STORAGE_ACCOUNT" = var.backend_storage_account
    "BACKEND_CONTAINER_NAME"  = var.backend_container
    "BACKEND_KEY"             = "${github_repository.this.name}.tfstate"
  }

  repository      = github_repository.this.name
  secret_name     = each.key
  plaintext_value = each.value

}

resource "github_repository_file" "workflow" {
  repository          = github_repository.this.name
  branch              = "main"
  file                = ".github/workflows/deploy.yml"
  content             = templatefile("${path.module}/templates/tf_action.yaml.tftpl", {})
  commit_message      = "chore: bootstrap caller workflow [skip ci]"
  overwrite_on_create = true
}

