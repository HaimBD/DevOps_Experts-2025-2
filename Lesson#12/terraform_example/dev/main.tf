provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "my-terraform-states"
    key            = "dev/s3.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}

resource "aws_s3_bucket" "dev_bucket" {
  bucket = "my-company-dev-bucket"
}