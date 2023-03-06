resource "aws_sns_topic_subscription" "web-notify" {
  topic_arn = var.push_topic_arn
  protocol  = "sqs"
  endpoint  = var.sqs_arn
}
