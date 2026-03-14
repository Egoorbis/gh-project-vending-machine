output "vending_machine_summary" {
  description = "Summary of all provisioned project infrastructure"
  value = {
    for key, repo_module in module.repo :
    key => {
      project_name   = repo_module.repo_html_url
      azure_identity = module.spn[key].azure_client_id
    }
  }
}
