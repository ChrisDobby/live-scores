data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "socket-disconnect" {
  name               = "socket-disconnect"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_policy" "dynamo" {
  name   = "socket-disconnect-dynamo"
  policy = data.aws_iam_policy_document.dynamo.json
}

data "aws_iam_policy_document" "dynamo" {
  statement {
    actions = ["dynamodb:DeleteItem"]

    resources = [
      var.connections_table_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "dynamo" {
  role       = aws_iam_role.socket-disconnect.name
  policy_arn = aws_iam_policy.dynamo.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.socket-disconnect.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
