resource "azuread_application" "this" {
  display_name = "spn-${var.repo_name}"
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
}

resource "azuread_application_federated_identity_credential" "this" {
  application_id = azuread_application.this.id
  display_name   = "github-actions-oidc"
  description    = "OIDC trust for GitHub Actions on main branch"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_owner}/${var.repo_name}:ref:refs/heads/main"
}

resource "azuread_application_federated_identity_credential" "pull_request" {
  application_id = azuread_application.this.id
  display_name   = "github-actions-oidc-pr"
  description    = "OIDC trust for GitHub Actions on pull requests"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_owner}/${var.repo_name}:pull_request"
}

resource "azurerm_role_assignment" "this" {
  scope                = "/subscriptions/${var.azure_subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.this.object_id
}