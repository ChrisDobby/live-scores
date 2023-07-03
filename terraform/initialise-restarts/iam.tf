data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "initialise-restarts" {
  name               = "initialise-restarts"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.initialise-restarts.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "dynamo-stream" {
  name   = "initialise-restarts-dynamo-stream"
  policy = data.aws_iam_policy_document.dynamo-stream.json
}

data "aws_iam_policy_document" "dynamo-stream" {
  statement {
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams",
      "dynamodb:Query",
    ]

    resources = [
      var.live_scores_table_arn,
      "${var.live_scores_table_arn}/*",
      "${var.live_scores_table_arn}/*/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "dynamo-stream" {
  role       = aws_iam_role.initialise-restarts.name
  policy_arn = aws_iam_policy.dynamo-stream.arn
}


resource "aws_iam_policy" "sqs" {
  name   = "initialise-restarts-sqs"
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions = ["sqs:SendMessage"]

    resources = [
      var.var.restart_schedule_queue_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.initialise-restarts.name
  policy_arn = aws_iam_policy.sqs.arn
}
