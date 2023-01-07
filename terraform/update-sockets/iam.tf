data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "update-sockets" {
  name               = "update-sockets"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.update-sockets.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "dynamo" {
  name   = "update-sockets-dynamo"
  policy = data.aws_iam_policy_document.dynamo.json
}

data "aws_iam_policy_document" "dynamo" {
  statement {
    actions = ["dynamodb:Scan"]

    resources = [
      var.connections_table_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "dynamo" {
  role       = aws_iam_role.update-sockets.name
  policy_arn = aws_iam_policy.dynamo.arn
}

resource "aws_iam_policy" "api" {
  name   = "update-sockets-api"
  policy = data.aws_iam_policy_document.api.json
}

data "aws_iam_policy_document" "api" {
  statement {
    actions = ["execute-api:Invoke", "execute-api:ManageConnections"]

    resources = [
      "${var.live_scores_execution_arn}/${var.live_scores_api_name}/POST/@connections/{connectionId}"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "api" {
  role       = aws_iam_role.update-sockets.name
  policy_arn = aws_iam_policy.api.arn
}
