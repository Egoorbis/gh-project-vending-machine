output "azure_client_id" {
  value = azuread_application.this.client_id
}

output "repo_name" {
  value = var.repo_name
}

output "service_principal_object_id" {
  value = azuread_service_principal.this.object_id
}

output "application_object_id" {
  value = azuread_application.this.object_id
}

output "oidc_subject_main" {
  value = azuread_application_federated_identity_credential.this.subject
}

output "oidc_subject_pull_request" {
  value = azuread_application_federated_identity_credential.pull_request.subject
}