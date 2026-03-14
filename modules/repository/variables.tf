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

variable "azure_client_id" {
  type      = string
  sensitive = true
}

variable "azure_subscription_id" {}
variable "azure_tenant_id" {}
variable "backend_resource_group" {}
variable "backend_storage_account" {}
variable "backend_container" {}