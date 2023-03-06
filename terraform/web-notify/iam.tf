data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "web-notify" {
  name               = "web-notify"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.web-notify.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}


resource "aws_iam_policy" "dynamo" {
  name   = "web-notify-dynamo"
  policy = data.aws_iam_policy_document.dynamo.json
}

data "aws_iam_policy_document" "dynamo" {
  statement {
    actions = ["dynamodb:Scan"]

    resources = [
      var.subscriptions_table_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "dynamo" {
  role       = aws_iam_role.web-notify.name
  policy_arn = aws_iam_policy.dynamo.arn
}

resource "aws_iam_policy" "sqs" {
  name   = "web-notify-sqs"
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      var.sqs_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.web-notify.name
  policy_arn = aws_iam_policy.sqs.arn
}
