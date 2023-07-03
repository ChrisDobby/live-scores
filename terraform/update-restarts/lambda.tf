resource "aws_lambda_function" "update-restarts" {
  function_name    = "update-restarts"
  handler          = "lib/index.handler"
  filename         = "../packages/functions/dist/update-restarts.zip"
  source_code_hash = filebase64sha256("../packages/functions/dist/update-restarts.zip")
  role             = aws_iam_role.update-restarts.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      RESTART_SCHEDULE_QUEUE_URL = var.restart_schedule_queue_url,
    }, {})
  }
}

resource "aws_lambda_permission" "update-restarts" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update-restarts.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.updated_topic_arn
}

resource "aws_cloudwatch_log_group" "update-restarts" {
  name              = "/aws/lambda/${aws_lambda_function.update-restarts.function_name}"
  retention_in_days = 14
}
