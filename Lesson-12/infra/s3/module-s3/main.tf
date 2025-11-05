resource "aws_s3_bucket" "s3-test" {

   bucket = var.bucket_name

   acl = var.acl_status

}