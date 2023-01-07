data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "get-scorecard-urls" {
  name               = "get-scorecard-urls"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_policy" "dynamo" {
  name   = "get-scorecard-urls-dynamo"
  policy = data.aws_iam_policy_document.dynamo.json
}

data "aws_iam_policy_document" "dynamo" {
  statement {
    actions = ["dynamodb:PutItem", "dynamodb:GetItem"]

    resources = [
      var.live_scores_table_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "dynamo" {
  role       = aws_iam_role.get-scorecard-urls.name
  policy_arn = aws_iam_policy.dynamo.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.get-scorecard-urls.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
