output "vending_machine_summary" {
  description = "Summary of all provisioned project infrastructure"
  value = {
    for key, repo_module in module.repo :
    key => {
      config_key         = key
      repository_name    = repo_module.repo_name
      repository_url     = repo_module.repo_html_url
      deploy_to_azure    = repo_module.deploy_to_azure
      configured_branch  = repo_module.update_branch
      azure_client_id    = try(module.spn[key].azure_client_id, null)
      azure_identity_set = try(module.spn[key].azure_client_id != "", false)
    }
  }
}
