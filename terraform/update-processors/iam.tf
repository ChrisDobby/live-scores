data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "update-processors" {
  name               = "update-processors"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.update-processors.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "ec2" {
  name   = "update-processors-ec2"
  policy = data.aws_iam_policy_document.ec2.json
}

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["ec2:DescribeInstances", "ec2:TerminateInstances"]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.update-processors.name
  policy_arn = aws_iam_policy.ec2.arn
}
