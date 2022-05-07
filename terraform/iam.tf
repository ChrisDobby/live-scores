data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
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

// consumer/Cloudwatch

resource "aws_iam_role_policy_attachment" "get-scorecard-urls-cloudwatch" {
  role       = aws_iam_role.get-scorecard-urls-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
