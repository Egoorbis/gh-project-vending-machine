locals {
  project_files = fileset("${path.module}/configs", "*.yaml")
  projects = {
    for f in local.project_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${path.module}/configs/${f}"))
  }
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
  update_branch            = lookup(each.value, "update_branch", null)
  deploy_to_azure          = lookup(each.value, "deploy_to_azure", true)

  azure_client_id         = try(module.spn[each.key].azure_client_id, "")
  azure_subscription_id   = var.azure_subscription_id
  azure_tenant_id         = var.azure_tenant_id
  backend_resource_group  = var.backend_resource_group
  backend_storage_account = var.backend_storage_account
  backend_container       = var.backend_container
}