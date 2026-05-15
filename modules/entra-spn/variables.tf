variable "repo_name" {
  type        = string
  description = "The name of the repository"

  validation {
    condition     = length(trimspace(var.repo_name)) > 0
    error_message = "repo_name must not be empty."
  }
}

variable "github_owner" {
  type        = string
  description = "The GitHub organization or user that owns the repository"

  validation {
    condition     = length(trimspace(var.github_owner)) > 0
    error_message = "github_owner must not be empty."
  }
}

variable "azure_subscription_id" {
  type = string

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.azure_subscription_id))
    error_message = "azure_subscription_id must be a GUID in the form xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}