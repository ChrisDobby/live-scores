resource "aws_sns_topic" "scorecard-updated" {
  name = "scorecard-updated"
}

resource "aws_sns_topic_subscription" "scorecard-updated-update-bucket" {
  topic_arn = aws_sns_topic.scorecard-updated.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.update-bucket.arn
}
