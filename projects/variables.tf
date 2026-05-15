variable "github_token" {
  description = "GitHub Personal Access Token with repo permissions"
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  type      = string
  sensitive = true

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.azure_subscription_id))
    error_message = "azure_subscription_id must be a GUID in the form xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}

variable "azure_tenant_id" {
  type      = string
  sensitive = true

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.azure_tenant_id))
    error_message = "azure_tenant_id must be a GUID in the form xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}

variable "backend_resource_group" {
  type      = string
  sensitive = true
}

variable "backend_storage_account" {
  type      = string
  sensitive = true
}

variable "backend_container" {
  type      = string
  sensitive = true
}

variable "github_owner" {
  type        = string
  description = "The GitHub organization or user that owns the repositories"
  default     = "Egoorbis"

  validation {
    condition     = length(trimspace(var.github_owner)) > 0
    error_message = "github_owner must not be empty."
  }
}
