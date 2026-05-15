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

variable "enable_code_scanning_gate" {
  type        = bool
  default     = true
  description = "When true, the branch ruleset will require a clean CodeQL scan (errors-level, high-or-higher security) before merging. Requires at least one successful CodeQL scan to exist before branch protection will pass."
}

variable "enable_push_ruleset" {
  type        = bool
  default     = true
  description = "Whether to create a push-target ruleset. GitHub only supports push rulesets for eligible org-owned repositories."
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