resource "aws_sns_topic_subscription" "scorecard-updated-push-notify" {
  topic_arn = var.updated_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.push-notify.arn
}
