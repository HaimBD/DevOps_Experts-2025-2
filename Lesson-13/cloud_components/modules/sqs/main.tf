resource "aws_sqs_queue" "this" {
  name                       = "ai-lab-app-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
}

output "queue_url" {
  value = aws_sqs_queue.this.id
}