resource "aws_lambda_function" "delete-web-subscription" {
  function_name    = "delete-web-subscription"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/delete-web-subscription.zip"
  source_code_hash = filebase64sha256("../functions/dist/delete-web-subscription.zip")
  role             = aws_iam_role.delete-web-subscription.arn

  runtime = "nodejs18.x"
  timeout = 10
}

resource "aws_lambda_event_source_mapping" "delete-web-subscription" {
  event_source_arn = var.sqs_arn
  function_name    = aws_lambda_function.delete-web-subscription.function_name
  batch_size       = 10
}

resource "aws_cloudwatch_log_group" "delete-web-subscription" {
  name              = "/aws/lambda/${aws_lambda_function.delete-web-subscription.function_name}"
  retention_in_days = 14
}
