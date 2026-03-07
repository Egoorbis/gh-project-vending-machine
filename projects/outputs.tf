output "vending_machine_summary" {
  description = "Summary of the newly provisioned project infrastructure"
  value = {
    project_name    = module.test_repo.repository_url
    azure_identity  = module.test_spn.azure_client_id
 }
}
