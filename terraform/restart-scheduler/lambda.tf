resource "aws_lambda_function" "restart-scheduler" {
  function_name    = "restart-scheduler"
  handler          = "lib/index.handler"
  filename         = "../packages/functions/dist/restart-scheduler.zip"
  source_code_hash = filebase64sha256("../packages/functions/dist/restart-scheduler.zip")
  role             = aws_iam_role.restart-scheduler.arn

  runtime = "nodejs18.x"
  timeout = 10
}

resource "aws_lambda_event_source_mapping" "restart-scheduler-sqs-source" {
  event_source_arn = var.restart_schedule_queue_arn
  function_name    = aws_lambda_function.restart-scheduler.function_name
  batch_size       = 10
}

resource "aws_cloudwatch_log_group" "restart-scheduler" {
  name              = "/aws/lambda/${aws_lambda_function.restart-scheduler.function_name}"
  retention_in_days = 14
}
