terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  required_version = "~> 1.8.0"
}

provider "github" {
  token = var.SECRETS_TOKEN
}

resource "github_repository_collaborator" "collaborator" {
  repository = var.repository_name
  username   = var.softserve_user
  permission = "admin"
}

resource "github_branch_default" "default_branch" {
  repository = var.repository_name
  branch     = "develop"
}

resource "github_branch_protection_v3" "develop_protection" {
  repository = var.repository_name
  branch     = "develop"

  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

resource "github_branch_protection_v3" "main_protection" {
  repository = var.repository_name
  branch     = "main"

  restrictions {
    users = [var.softserve_user]
  }

  required_pull_request_reviews {
    require_code_owner_reviews      = true
    required_approving_review_count = 1
    dismissal_users                 = [var.softserve_user]
  }
}

resource "tls_private_key" "deploy_key" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = var.repository_name
  title      = "DEPLOY_KEY"
  key        = tls_private_key.deploy_key.public_key_openssh
  read_only  = true
}

resource "github_actions_secret" "name" {
  repository  = var.repository_name
  secret_name = "TERRAFORM"
}
