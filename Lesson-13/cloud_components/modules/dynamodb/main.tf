resource "aws_dynamodb_table" "this" {
  name           = "ai-lab-dynamodb"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "lab"
    Project     = "ai-lab"
  }
}