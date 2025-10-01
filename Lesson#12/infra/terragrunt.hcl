remote_state {
  backend = "s3"
  config = {
    bucket         = "terragrunt-lock-alexk"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lock-terragrunt-alexk"
    encrypt        = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {}
}
EOF
}
