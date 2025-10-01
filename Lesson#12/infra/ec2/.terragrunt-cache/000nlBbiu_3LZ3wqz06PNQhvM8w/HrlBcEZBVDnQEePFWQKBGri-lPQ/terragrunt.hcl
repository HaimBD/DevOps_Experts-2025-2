include {
  path = find_in_parent_folders()
}

terraform {
  source = "./module-ec2"
}

inputs = {
  ami           = "ami-0360c520857e3138" # Ubuntu 22.04 in us-east-1
  instance_type = "t2.micro"
}
