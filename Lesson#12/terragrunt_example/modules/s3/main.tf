provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

variable "bucket_name" {
  type = string
}