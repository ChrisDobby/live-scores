resource "aws_sns_topic" "scorecard-updated" {
  name = "scorecard-updated"
}

resource "aws_sns_topic_subscription" "scorecard-updated-update-bucket" {
  topic_arn = aws_sns_topic.scorecard-updated.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.update-bucket.arn
}

resource "aws_sns_topic_subscription" "scorecard-updated-update-processors" {
  topic_arn = aws_sns_topic.scorecard-updated.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.update-processors.arn
}

resource "aws_sns_topic_subscription" "scorecard-updated-update-sanity" {
  topic_arn = aws_sns_topic.scorecard-updated.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.update-sanity.arn
}
