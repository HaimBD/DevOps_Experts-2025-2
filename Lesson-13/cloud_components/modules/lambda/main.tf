resource "aws_iam_role" "lambda_role" {
  name = "ai-lab-lambda-rekognition-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

# Permissions: CloudWatch logs, S3, SQS, Rekognition
resource "aws_iam_role_policy" "lambda_policy" {
  name = "ai-lab-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rekognition:DetectLabels",
          "rekognition:DetectModerationLabels",
          "rekognition:DetectText"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "this" {
  filename         = "${path.module}/lambda.zip"
  function_name    = "ai-lab-rekognition-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
      QUEUE_URL   = var.queue_url
    }
  }
}

# Allow S3 to trigger Lambda
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"
}

# Add bucket event notification
resource "aws_s3_bucket_notification" "s3_event" {
  bucket = var.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}