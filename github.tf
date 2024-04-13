terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  required_version = "~> 1.8.0"
}

provider "github" {}

resource "github_repository_collaborator" "collaborator" {
  repository = var.repository_name
  username   = var.softserve_user
  permission = "admin"
}

resource "github_branch_default" "default_branch" {
  repository = var.repository_name
  branch     = "develop"
}

resource "github_branch_protection" "develop_protection" {
  repository_id = var.repository_name
  pattern       = "develop"

  enforce_admins         = true
  require_signed_commits = true
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 2
  }
}

resource "github_branch_protection" "main_protection" {
  repository_id = var.repository_name
  pattern       = "main"

  enforce_admins         = true
  require_signed_commits = true
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 0
  }
}

resource "tls_private_key" "deploy_key" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = var.repository_name
  title      = "DEPLOY_KEY"
  key        = tls_private_key.deploy_key.public_key_openssh
}

resource "github_actions_secret" "name" {
  repository  = var.repository_name
  secret_name = "PAT"
}
