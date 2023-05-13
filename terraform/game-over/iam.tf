data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "game-over" {
  name               = "game-over"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.game-over.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "sns" {
  name   = "game-over-sns"
  policy = data.aws_iam_policy_document.sns.json
}

data "aws_iam_policy_document" "sns" {
  statement {
    effect  = "Allow"
    actions = ["sns:Publish"]

    resources = [var.game_over_topic_arn]
  }
}

resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.game-over.name
  policy_arn = aws_iam_policy.sns.arn
}
