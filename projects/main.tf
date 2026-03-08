# 1. Vend the Identity
module "test_spn" {
  source          = "../modules/entra-spn"
  repo_name     = "add-workflow-to-repo"
  azure_subscription_id = var.azure_subscription_id
}

# 2. Vend the Repository
module "test_repo" {
  source      = "../modules/repository"
  repo_name   = module.test_spn.repo_name
  description = "This repo was created entirely via Terraform and GitHub Apps."
  
  additional_topics = ["terraform", "testing"]

  azure_client_id       = module.test_spn.azure_client_id
  azure_subscription_id = var.azure_subscription_id
  azure_tenant_id       = var.azure_tenant_id
  backend_resource_group = var.backend_resource_group
  backend_storage_account = var.backend_storage_account
  backend_container = var.backend_container
}