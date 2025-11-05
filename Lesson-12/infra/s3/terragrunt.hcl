include {
  path = find_in_parent_folders()
}

terraform {
  source = "./module-s3"
}

inputs = {
  bucket_name = "hbd-s3-test",
  acl_status = "private"
}
