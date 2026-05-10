terraform {
  backend "azurerm" {
    use_oidc         = true
    use_azuread_auth = true
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "Egoorbis"
  token = var.github_token
}

provider "azurerm" {
  features {

  }
  use_oidc = true
}

provider "azuread" {}