resource "aws_sns_topic_subscription" "scorecard-updated-game-over" {
  topic_arn = var.updated_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.game-over.arn
}
