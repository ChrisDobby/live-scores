resource "aws_sns_topic_subscription" "game-over-update-processors" {
  topic_arn = var.game_over_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.update-processors.arn
}
