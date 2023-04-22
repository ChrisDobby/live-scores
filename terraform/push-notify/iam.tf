data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "push-notify" {
  name               = "push-notify"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.push-notify.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "s3" {
  name   = "push-notify-s3"
  policy = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.notifications.arn,
      "${aws_s3_bucket.notifications.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.push-notify.name
  policy_arn = aws_iam_policy.s3.arn
}


resource "aws_iam_policy" "sns" {
  name   = "push-notify-sns"
  policy = data.aws_iam_policy_document.sns.json
}

data "aws_iam_policy_document" "sns" {
  statement {
    effect  = "Allow"
    actions = ["sns:Publish"]

    resources = [var.push_topic_arn]
  }
}

resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.push-notify.name
  policy_arn = aws_iam_policy.sns.arn
}
