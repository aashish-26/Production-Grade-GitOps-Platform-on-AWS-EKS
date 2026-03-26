// SQS queue module

variable "name" { type = string }
variable "tags" { type = map(string) }

resource "aws_sqs_queue" "queue" {
  name = var.name

  // Use a redrive policy and visibility timeout suitable for your job processing
  visibility_timeout_seconds = 60
  delay_seconds              = 0
  message_retention_seconds  = 1209600 // 14 days

  tags = merge(var.tags, { service = "worker-queue" })
}

output "queue_url" {
  value = aws_sqs_queue.queue.id
}

output "queue_arn" {
  value = aws_sqs_queue.queue.arn
}
