data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "create-processors" {
  name               = "create-processors"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.create-processors.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "dynamo-stream" {
  name   = "create-processors-dynamo-stream"
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
  role       = aws_iam_role.create-processors.name
  policy_arn = aws_iam_policy.dynamo-stream.arn
}

resource "aws_iam_policy" "iam" {
  name   = "create-processors-iam"
  policy = data.aws_iam_policy_document.iam.json
}

data "aws_iam_policy_document" "iam" {
  statement {
    actions = ["iam:*"]

    resources = [
      var.scorecard_processor_instance_profile_arn,
      var.scorecard_processor_role_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "iam" {
  role       = aws_iam_role.create-processors.name
  policy_arn = aws_iam_policy.iam.arn
}

resource "aws_iam_policy" "ec2" {
  name   = "create-processors-ec2"
  policy = data.aws_iam_policy_document.ec2.json
}

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["ec2:RunInstances", "ec2:CreateTags"]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.create-processors.name
  policy_arn = aws_iam_policy.ec2.arn
}
