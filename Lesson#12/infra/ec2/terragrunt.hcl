terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/ec2-instance/aws?version=5.6.0"
}

inputs = {
  name          = "terragrunt-ec2"
  ami           = "ami-07b7f66b629de9364"  # Ubuntu 22.04 in us-east-1
  instance_type = "t2.micro"

  tags = {
    Environment = "dev"
    Project     = "terragrunt-demo"
  }
}