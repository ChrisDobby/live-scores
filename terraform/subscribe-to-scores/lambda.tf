resource "aws_lambda_function" "subscribe-to-scores" {
  function_name    = "subscribe-to-scores"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/subscribe-to-scores.zip"
  source_code_hash = filebase64sha256("../functions/dist/subscribe-to-scores.zip")
  role             = aws_iam_role.subscribe-to-scores.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      WEB_NOTIFY_QUEUE_URL = var.web_notify_queue_url,
    }, {})
  }
}

resource "aws_lambda_permission" "subscribe-to-scores" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscribe-to-scores.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.notifications_execution_arn}/*/*/*"
}

resource "aws_cloudwatch_log_group" "subscribe-to-scores" {
  name              = "/aws/lambda/${aws_lambda_function.subscribe-to-scores.function_name}"
  retention_in_days = 14
}
