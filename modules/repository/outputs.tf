output "repo_html_url" {
  value = github_repository.this.html_url
}

output "repo_name" {
  value = github_repository.this.name
}

output "deploy_to_azure" {
  value = var.deploy_to_azure
}

output "update_branch" {
  value = var.update_branch
}