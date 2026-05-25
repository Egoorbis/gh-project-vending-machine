variable "repo_name" {
  type        = string
  description = "The name of the repository"
}

variable "description" {
  type        = string
  description = "Description for the repo"
}

variable "repository_visibility" {
  type        = string
  default     = "public"
  description = "Repository visibility. Push rulesets are only created for non-public repositories."
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
  default     = false
  description = "Legacy field kept for backward compatibility. Push rulesets are org-only and are not supported for this personal-account vending machine."
}

variable "enable_codeql_default_setup" {
  type        = bool
  default     = true
  description = "Whether to bootstrap CodeQL for the vended repository."
}

variable "enable_dependabot_alerts" {
  type        = bool
  default     = true
  description = "Whether Dependabot vulnerability alerts should be enabled by default."
}

variable "enable_dependabot_security_updates" {
  type        = bool
  default     = true
  description = "Whether Dependabot security update pull requests should be enabled by default."
}

variable "enable_dependabot_grouped_updates" {
  type        = bool
  default     = true
  description = "Whether Dependabot grouped security updates should be enabled by default."
}

variable "enable_dependency_graph" {
  type        = bool
  default     = true
  description = "Whether Dependency graph should be enabled by default."
}

variable "deploy_to_azure" {
  type        = bool
  default     = true
  description = "Whether to configure Azure integration (Entra SPN, secrets, and workflow) for this repository. When false, no Azure resources or secrets are created."
}

variable "update_branch" {
  type        = string
  default     = null
  description = "Optional branch name used by bootstrap workflows to propose updates via PR when branch protection is enabled."
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