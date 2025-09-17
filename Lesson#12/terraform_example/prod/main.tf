provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "my-terraform-states"
    key            = "prod/s3.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}

resource "aws_s3_bucket" "prod_bucket" {
  bucket = "my-company-prod-bucket"
}