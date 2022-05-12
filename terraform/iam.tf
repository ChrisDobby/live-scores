data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "get-scorecard-urls-role" {
  name               = "get-scorecard-urls"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_policy" "get-scorecard-urls-dynamo" {
  name   = "get-scorecard-urls-dynamo"
  policy = data.aws_iam_policy_document.get-scorecard-urls-dynamo.json
}

data "aws_iam_policy_document" "get-scorecard-urls-dynamo" {
  statement {
    actions = ["dynamodb:PutItem", "dynamodb:GetItem"]

    resources = [
      aws_dynamodb_table.live-score-urls.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "get-scorecard-urls-dynamo" {
  role       = aws_iam_role.get-scorecard-urls-role.name
  policy_arn = aws_iam_policy.get-scorecard-urls-dynamo.arn
}

resource "aws_iam_role_policy_attachment" "get-scorecard-urls-cloudwatch" {
  role       = aws_iam_role.get-scorecard-urls-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "scorecard-processor-role" {
  name               = "scorecard-processor-role"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-role.json
}

resource "aws_iam_policy" "scorecard-processor-dynamo" {
  name   = "scorecard-processor-dynamo"
  policy = data.aws_iam_policy_document.scorecard-processor-dynamo.json
}

data "aws_iam_policy_document" "scorecard-processor-dynamo" {
  statement {
    actions = ["dynamodb:GetItem", "dynamodb:Query"]

    resources = [
      aws_dynamodb_table.live-score-urls.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "scorecard-processor-dynamo" {
  role       = aws_iam_role.scorecard-processor-role.name
  policy_arn = aws_iam_policy.scorecard-processor-dynamo.arn
}

resource "aws_iam_policy" "scorecard-processor-s3" {
  name   = "scorecard-processor-s3"
  policy = data.aws_iam_policy_document.scorecard-processor-s3.json
}

data "aws_iam_policy_document" "scorecard-processor-s3" {
  statement {
    actions = ["s3:PutItem"]

    resources = [
      aws_s3_bucket.live-scores-html.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "scorecard-processor-s3" {
  role       = aws_iam_role.scorecard-processor-role.name
  policy_arn = aws_iam_policy.scorecard-processor-s3.arn
}

resource "aws_iam_instance_profile" "scorecard-processor-profile" {
  name = "scorecard-processor-profile"
  role = aws_iam_role.scorecard-processor-role.name
}

resource "aws_iam_role" "create-processors-role" {
  name               = "create-processors"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "create-processors-cloudwatch" {
  role       = aws_iam_role.create-processors-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "create-processors-dynamo-stream" {
  name   = "create-processors-dynamo-stream"
  policy = data.aws_iam_policy_document.create-processors-dynamo-stream.json
}

data "aws_iam_policy_document" "create-processors-dynamo-stream" {
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
      aws_dynamodb_table.live-score-urls.arn,
      "${aws_dynamodb_table.live-score-urls.arn}/*",
      "${aws_dynamodb_table.live-score-urls.arn}/*/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "create-processors-dynamo-stream" {
  role       = aws_iam_role.create-processors-role.name
  policy_arn = aws_iam_policy.create-processors-dynamo-stream.arn
}

resource "aws_iam_policy" "create-processors-dynamo" {
  name   = "create-processors-dynamo"
  policy = data.aws_iam_policy_document.create-processors-dynamo.json
}

data "aws_iam_policy_document" "create-processors-dynamo" {
  statement {
    actions = ["dynamodb:GetItem", "dynamodb:Query"]

    resources = [aws_dynamodb_table.running-processors.arn]
  }
}

resource "aws_iam_role_policy_attachment" "create-processors-dynamo" {
  role       = aws_iam_role.create-processors-role.name
  policy_arn = aws_iam_policy.create-processors-dynamo.arn
}

resource "aws_iam_policy" "create-processors-iam" {
  name   = "create-processors-iam"
  policy = data.aws_iam_policy_document.create-processors-iam.json
}

data "aws_iam_policy_document" "create-processors-iam" {
  statement {
    actions = ["iam:GetRole", "iam: GetInstanceProfile"]

    resources = [
      "${aws_iam_role.create-processors-role.arn}/*",
      "${aws_iam_instance_profile.scorecard-processor-profile.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "create-processors-iam" {
  role       = aws_iam_role.create-processors-role.name
  policy_arn = aws_iam_policy.create-processors-iam.arn
}

resource "aws_iam_policy" "create-processors-ec2" {
  name   = "create-processors-ec2"
  policy = data.aws_iam_policy_document.create-processors-ec2.json
}

data "aws_iam_policy_document" "create-processors-ec2" {
  statement {
    actions = ["ec2:RunInstances"]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "create-processors-ec2" {
  role       = aws_iam_role.create-processors-role.name
  policy_arn = aws_iam_policy.create-processors-ec2.arn
}
