resource "aws_lambda_function" "create-scorecard" {
  function_name    = "create-scorecard"
  handler          = "lib/index.handler"
  filename         = "../packages/functions/dist/create-scorecard.zip"
  source_code_hash = filebase64sha256("../packages/functions/dist/create-scorecard.zip")
  role             = aws_iam_role.create-scorecard.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      UPDATE_SNS_TOPIC_ARN  = var.updated_topic_arn,
    }, {})
  }
}

resource "aws_lambda_event_source_mapping" "create-scorecard-sqs-source" {
  event_source_arn = var.html_sqs_arn
  function_name    = aws_lambda_function.create-scorecard.function_name
  batch_size       = 10
}

resource "aws_cloudwatch_log_group" "create-scorecard" {
  name              = "/aws/lambda/${aws_lambda_function.create-scorecard.function_name}"
  retention_in_days = 14
}
