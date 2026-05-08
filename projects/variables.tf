variable "github_token" {
  description = "GitHub Personal Access Token with repo permissions"
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" { 
  type = string 
  sensitive = true
}

variable "azure_tenant_id" { 
  type = string 
  sensitive = true
}

variable "backend_resource_group" {
  type = string
  sensitive = true
}

variable "backend_storage_account" { 
  type = string 
  sensitive = true
}

variable "backend_container" { 
  type = string 
  sensitive = true
}

variable "github_owner" {
  type        = string
  description = "The GitHub organization or user that owns the repositories"
  default     = "Egoorbis"
}
