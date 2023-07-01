resource "aws_sqs_queue" "scorecard-html" {
  name                       = "scorecard-html"
  message_retention_seconds  = 300
  visibility_timeout_seconds = 60
}
