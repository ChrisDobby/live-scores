resource "aws_sns_topic_subscription" "scorecard-updated-update-sanity" {
  topic_arn = var.updated_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.update-sanity.arn
}
