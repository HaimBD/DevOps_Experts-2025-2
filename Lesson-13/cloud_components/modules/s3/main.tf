resource "random_id" "rand" {
  byte_length = 4
}

resource "aws_s3_bucket" "this" {
  bucket        = "ai-lab-app-${random_id.rand.hex}"
  force_destroy = true
}

output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}