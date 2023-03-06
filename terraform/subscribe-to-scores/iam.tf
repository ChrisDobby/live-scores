data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "subscribe-to-scores" {
  name               = "subscribe-to-scores"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.subscribe-to-scores.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}


resource "aws_iam_policy" "dynamo" {
  name   = "subscribe-to-scores-dynamo"
  policy = data.aws_iam_policy_document.dynamo.json
}

data "aws_iam_policy_document" "dynamo" {
  statement {
    actions = ["dynamodb:PutItem", "dynamodb:DeleteItem"]

    resources = [
      var.subscriptions_table_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "dynamo" {
  role       = aws_iam_role.subscribe-to-scores.name
  policy_arn = aws_iam_policy.dynamo.arn
}


resource "aws_iam_policy" "sqs" {
  name   = "subscribe-to-scores-sqs"
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions = ["sqs:SendMessage"]

    resources = [
      var.web_notify_queue_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.subscribe-to-scores.name
  policy_arn = aws_iam_policy.sqs.arn
}
