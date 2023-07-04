data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "update-restarts" {
  name               = "update-restarts"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.update-restarts.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "sqs" {
  name   = "update-restarts-sqs"
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions = ["sqs:SendMessage"]

    resources = [
      var.restart_schedule_queue_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.update-restarts.name
  policy_arn = aws_iam_policy.sqs.arn
}
