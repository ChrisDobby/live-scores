data "aws_iam_policy_document" "states-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "restart-processor" {
  name               = "restart-processor"
  assume_role_policy = data.aws_iam_policy_document.states-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.restart-processor.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "dynamo" {
  name   = "restart-processor-dynamo"
  policy = data.aws_iam_policy_document.dynamo.json
}

data "aws_iam_policy_document" "dynamo" {
  statement {
    actions = ["dynamodb:DeleteItem"]

    resources = [
      var.live_scores_table_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "dynamo" {
  role       = aws_iam_role.restart-processor.name
  policy_arn = aws_iam_policy.dynamo.arn
}

resource "aws_iam_policy" "lambda" {
  name   = "restart-processor-lambda"
  policy = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["lambda:InvokeFunction"]

    resources = [
      var.get_scorecard_urls_arn,
      var.var.teardown_processors_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.restart-processor.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_iam_policy" "x-ray" {
  name   = "restart-processor-x-ray"
  policy = data.aws_iam_policy_document.x-ray.json
}

data "aws_iam_policy_document" "x-ray" {
  statement {
    actions = [ "xray:PutTraceSegments", "xray:PutTelemetryRecords", "xray:GetSamplingRules", "xray:GetSamplingTargets"]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "x-ray" {
  role       = aws_iam_role.restart-processor.name
  policy_arn = aws_iam_policy.x-ray.arn
}
