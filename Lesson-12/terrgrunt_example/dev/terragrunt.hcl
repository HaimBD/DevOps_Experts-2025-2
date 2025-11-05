terraform {
  source = "../modules/s3"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-states"
    key            = "dev/s3.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}

inputs = {
  bucket_name = "hbd-bucket-grunt"
}
