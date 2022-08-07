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

resource "aws_iam_policy" "scorecard-processor-sqs" {
  name   = "scorecard-processor-sqs"
  policy = data.aws_iam_policy_document.scorecard-processor-sqs.json
}

data "aws_iam_policy_document" "scorecard-processor-sqs" {
  statement {
    actions = ["sqs:SendMessage"]

    resources = [
      aws_sqs_queue.first-team-scorecard-html.arn,
      aws_sqs_queue.second-team-scorecard-html.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "scorecard-processor-sqs" {
  role       = aws_iam_role.scorecard-processor-role.name
  policy_arn = aws_iam_policy.scorecard-processor-sqs.arn
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

resource "aws_iam_policy" "create-processors-iam" {
  name   = "create-processors-iam"
  policy = data.aws_iam_policy_document.create-processors-iam.json
}

data "aws_iam_policy_document" "create-processors-iam" {
  statement {
    actions = ["iam:*"]

    resources = [
      "${aws_iam_role.scorecard-processor-role.arn}",
      "${aws_iam_instance_profile.scorecard-processor-profile.arn}"
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
    actions = ["ec2:RunInstances", "ec2:CreateTags"]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "create-processors-ec2" {
  role       = aws_iam_role.create-processors-role.name
  policy_arn = aws_iam_policy.create-processors-ec2.arn
}

resource "aws_iam_role" "teardown-processors-role" {
  name               = "teardown-processors"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "teardown-processors-cloudwatch" {
  role       = aws_iam_role.teardown-processors-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "teardown-processors-ec2" {
  name   = "teardown-processors-ec2"
  policy = data.aws_iam_policy_document.teardown-processors-ec2.json
}

data "aws_iam_policy_document" "teardown-processors-ec2" {
  statement {
    actions = ["ec2:DescribeInstances", "ec2:TerminateInstances"]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "teardown-processors-ec2" {
  role       = aws_iam_role.teardown-processors-role.name
  policy_arn = aws_iam_policy.teardown-processors-ec2.arn
}

resource "aws_iam_role" "create-scorecard-role" {
  name               = "create-scorecard"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "create-scorecard-cloudwatch" {
  role       = aws_iam_role.create-scorecard-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "create-scorecard-sqs" {
  name   = "create-scorecard-sqs"
  policy = data.aws_iam_policy_document.create-scorecard-sqs.json
}

data "aws_iam_policy_document" "create-scorecard-sqs" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.first-team-scorecard-html.arn,
      aws_sqs_queue.second-team-scorecard-html.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "create-scorecard-sqs" {
  role       = aws_iam_role.create-scorecard-role.name
  policy_arn = aws_iam_policy.create-scorecard-sqs.arn
}

resource "aws_iam_policy" "create-scorecard-s3" {
  name   = "create-scorecard-s3"
  policy = data.aws_iam_policy_document.create-scorecard-s3.json
}

data "aws_iam_policy_document" "create-scorecard-s3" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      "${aws_s3_bucket.scorecards.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "create-scorecard-s3" {
  role       = aws_iam_role.create-scorecard-role.name
  policy_arn = aws_iam_policy.create-scorecard-s3.arn
}


resource "aws_iam_policy" "create-scorecard-sns" {
  name   = "create-scorecard-sns"
  policy = data.aws_iam_policy_document.create-scorecard-sns.json
}

data "aws_iam_policy_document" "create-scorecard-sns" {
  statement {
    effect  = "Allow"
    actions = ["sns:Publish"]

    resources = [aws_sns_topic.scorecard-updated.arn]
  }
}

resource "aws_iam_role_policy_attachment" "create-scorecard-sns" {
  role       = aws_iam_role.create-scorecard-role.name
  policy_arn = aws_iam_policy.create-scorecard-sns.arn
}

resource "aws_iam_role" "socket-connect-role" {
  name               = "socket-connect"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_policy" "socket-connect-dynamo" {
  name   = "socket-connect-dynamo"
  policy = data.aws_iam_policy_document.socket-connect-dynamo.json
}

data "aws_iam_policy_document" "socket-connect-dynamo" {
  statement {
    actions = ["dynamodb:PutItem"]

    resources = [
      aws_dynamodb_table.live-score-connections.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "socket-connect-dynamo" {
  role       = aws_iam_role.socket-connect-role.name
  policy_arn = aws_iam_policy.socket-connect-dynamo.arn
}

resource "aws_iam_role_policy_attachment" "socket-connect-cloudwatch" {
  role       = aws_iam_role.socket-connect-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
resource "aws_iam_role" "socket-disconnect-role" {
  name               = "socket-disconnect"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_policy" "socket-disconnect-dynamo" {
  name   = "socket-disconnect-dynamo"
  policy = data.aws_iam_policy_document.socket-disconnect-dynamo.json
}

data "aws_iam_policy_document" "socket-disconnect-dynamo" {
  statement {
    actions = ["dynamodb:DeleteItem"]

    resources = [
      aws_dynamodb_table.live-score-connections.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "socket-disconnect-dynamo" {
  role       = aws_iam_role.socket-disconnect-role.name
  policy_arn = aws_iam_policy.socket-disconnect-dynamo.arn
}

resource "aws_iam_role_policy_attachment" "socket-disconnect-cloudwatch" {
  role       = aws_iam_role.socket-disconnect-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "update-bucket-role" {
  name               = "update-bucket"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "update-bucket-cloudwatch" {
  role       = aws_iam_role.update-bucket-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "update-bucket-s3" {
  name   = "update-bucket-s3"
  policy = data.aws_iam_policy_document.update-bucket-s3.json
}

data "aws_iam_policy_document" "update-bucket-s3" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      "${aws_s3_bucket.scorecards.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "update-bucket-s3" {
  role       = aws_iam_role.update-bucket-role.name
  policy_arn = aws_iam_policy.update-bucket-s3.arn
}


resource "aws_iam_role" "game-over-role" {
  name               = "game-over"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "game-over-cloudwatch" {
  role       = aws_iam_role.game-over-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "update-processors-role" {
  name               = "update-processors"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "update-processors-cloudwatch" {
  role       = aws_iam_role.update-processors-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "update-sanity-role" {
  name               = "update-sanity"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "update-sanity-cloudwatch" {
  role       = aws_iam_role.update-sanity-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
