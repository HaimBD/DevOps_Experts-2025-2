include {
  path = find_in_parent_folders()
}

terraform {
  source = "./module-ec2"
}

inputs = {
  ami           = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
}
