variable "repo_name" {
  type        = string
  description = "The name of the repository"
}

variable "description" {
  type        = string
  description = "Description for the repo"
}

variable "additional_topics" {
  type    = list(string)
  default = []
}

variable "enable_branch_protection" {
  type        = bool
  default     = true
  description = "Whether to enable branch protection on the main branch"
}

variable "update_branch" {
  type        = string
  default     = null
  description = "Name of a dedicated branch to create for updates when branch protection is enabled. If null, no update branch is created."
}

variable "deploy_to_azure" {
  type        = bool
  default     = true
  description = "Whether to configure Azure integration (Entra SPN, secrets, and workflow) for this repository. When false, no Azure resources or secrets are created."
}

variable "azure_client_id" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Azure AD application client ID for OIDC authentication. Only required when deploy_to_azure is true."
}

variable "azure_subscription_id" {
  type        = string
  default     = ""
  description = "Azure subscription ID. Only required when deploy_to_azure is true."
}

variable "azure_tenant_id" {
  type        = string
  default     = ""
  description = "Azure tenant ID. Only required when deploy_to_azure is true."
}

variable "backend_resource_group" {
  type        = string
  default     = ""
  description = "Azure resource group for Terraform backend state. Only required when deploy_to_azure is true."
}

variable "backend_storage_account" {
  type        = string
  default     = ""
  description = "Azure storage account for Terraform backend state. Only required when deploy_to_azure is true."
}

variable "backend_container" {
  type        = string
  default     = ""
  description = "Azure storage container for Terraform backend state. Only required when deploy_to_azure is true."
}