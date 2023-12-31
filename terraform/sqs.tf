resource "aws_sqs_queue" "scorecard-html" {
  name                       = "scorecard-html"
  message_retention_seconds  = 300
  visibility_timeout_seconds = 60
}

resource "aws_sqs_queue" "web-notify" {
  name                       = "web-notify"
  message_retention_seconds  = 60
  visibility_timeout_seconds = 60
}

resource "aws_sqs_queue" "delete-notification-subscription" {
  name                       = "delete-notification-subscription"
  message_retention_seconds  = 300
  visibility_timeout_seconds = 60
}

data "aws_iam_policy_document" "web-notify" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.web-notify.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.push-notification.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "web-notify" {
  queue_url = aws_sqs_queue.web-notify.id
  policy    = data.aws_iam_policy_document.web-notify.json
}
