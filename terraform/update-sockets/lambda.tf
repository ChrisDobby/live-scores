resource "aws_lambda_function" "update-sockets" {
  function_name    = "update-sockets"
  handler          = "lib/index.handler"
  filename         = "../packages/functions/dist/update-sockets.zip"
  source_code_hash = filebase64sha256("../packages/functions/dist/update-sockets.zip")
  role             = aws_iam_role.update-sockets.arn

  runtime = "nodejs18.x"
  timeout = 30

  environment {
    variables = merge({
      SOCKET_ENDPOINT          = replace(var.invoke_url, "wss://", "https://"),
      CONNECTIONS_TABLE_SUFFIX = var.connections-table-suffix,
    }, {})
  }
}

resource "aws_lambda_permission" "update-sockets" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update-sockets.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.updated_topic_arn
}

resource "aws_cloudwatch_log_group" "update-sockets" {
  name              = "/aws/lambda/${aws_lambda_function.update-sockets.function_name}"
  retention_in_days = 14
}
