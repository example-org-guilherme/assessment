locals {
  repos = {
    application = {
      description             = "Example application that uses submodules and github workflows to release and update modules periodically :)",
      additional_setup_script = <<-EOT

      sleep 60 # waiting for submodules

      # Add submodules according to .gitmodules
      git config -f .gitmodules --get-regexp '^submodule\..*\.path$' |
      while read path_key local_path
      do
          url_key=$(echo $path_key | sed 's/\.path/.url/')
          url=$(git config -f .gitmodules --get "$url_key" | sed s/github.com/x-access-token:$GITHUB_TOKEN@github.com/)
          rm -r $local_path || true
          git submodule add $url $local_path
      done

      EOT
    }
    submodule-a = {
      description = "Example git submodule a",
    }
    submodule-b = {
      description = "Example git submodule b",
    }
    submodule-c = {
      description = "Example git submodule c",
    }
    gha-workflows = {
      description              = "Shared Github Actions Workflows :)"
      allow_reusable_workflows = true
    }
  }
}

resource "github_repository" "this" {
  for_each = local.repos

  name        = each.key
  description = each.value.description

  visibility = "private"

  provisioner "local-exec" {
    environment = {
      GITHUB_TOKEN = var.token
    }
    command = <<-EOT
    set -e
    set -x

    cd ../repos/${each.key}/

    # Configure current user
    git config --global user.email "terraform@example.com"
    git config --global user.name "Terraform Automation"

    # Cleanup git repo
    rm -rf .git

    # Initi 
    git init -b main

    # Credentials for submodules
    auth_header="Authorization: Basic $(echo x-access-token:$GITHUB_TOKEN | base64 -w 0)"

    ${try(each.value.additional_setup_script, "")}
    
    # Replace "template" values
    find . -type f -exec sed -i s/elevate-labs-with-guilherme/${var.owner}/g {} \;

    # Push it :)
    git add . 
    git commit -m 'initial commit'
    git remote add origin https://x-access-token:$GITHUB_TOKEN@github.com/${var.owner}/${each.key}.git

    git push origin main
    git remote remove origin

    rm .git/config

    EOT
  }
}

#
# Allow actions and reusable workflows :)
#

resource "github_actions_repository_permissions" "this" {
  for_each = local.repos

  enabled         = true
  allowed_actions = "all"

  repository = github_repository.this[each.key].name
}

resource "github_actions_repository_access_level" "this" {
  for_each = local.repos

  access_level = "organization"
  repository   = github_repository.this[each.key].name
}

resource "github_actions_secret" "github_token" {
  for_each = local.repos

  repository      = github_repository.this[each.key].name
  secret_name     = "GH_TOKEN"
  plaintext_value = var.token
}

# Manual steps afterwards
# - add GH_TOKEN to application
# - allow execution of workflows from gha-workflows
