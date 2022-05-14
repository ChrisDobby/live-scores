resource "aws_sqs_queue" "first-team-scorecard-html" {
  name                       = "first-team-scorecard-html"
  message_retention_seconds  = 300
  visibility_timeout_seconds = 60
}

resource "aws_sqs_queue" "second-team-scorecard-html" {
  name                       = "second-team-scorecard-html"
  message_retention_seconds  = 300
  visibility_timeout_seconds = 60
}
