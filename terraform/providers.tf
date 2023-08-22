terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

terraform {
  backend "local" { path = "tfstate/terraform.tfstate" }
}

provider "github" {
  owner = var.owner
  token = var.token
}