data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "create-scorecard" {
  name               = "create-scorecard"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.create-scorecard.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "sqs" {
  name   = "create-scorecard-sqs"
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      var.html_sqs_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.create-scorecard.name
  policy_arn = aws_iam_policy.sqs.arn
}

resource "aws_iam_policy" "sns" {
  name   = "create-scorecard-sns"
  policy = data.aws_iam_policy_document.sns.json
}

data "aws_iam_policy_document" "sns" {
  statement {
    effect  = "Allow"
    actions = ["sns:Publish"]

    resources = [var.updated_topic_arn]
  }
}

resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.create-scorecard.name
  policy_arn = aws_iam_policy.sns.arn
}
