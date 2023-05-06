data "aws_iam_policy_document" "ec2-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "scorecard-processor" {
  name               = "scorecard-processor-role"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-role.json
}

resource "aws_iam_policy" "sqs" {
  name   = "scorecard-processor-sqs"
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions = ["sqs:SendMessage"]

    resources = [
      var.html_sqs_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.scorecard-processor.name
  policy_arn = aws_iam_policy.sqs.arn
}

resource "aws_iam_instance_profile" "scorecard-processor" {
  name = "scorecard-processor-profile"
  role = aws_iam_role.scorecard-processor.name
}









