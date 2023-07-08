resource "aws_lambda_function" "socket-connect" {
  function_name    = "socket-connect"
  handler          = "lib/index.handler"
  filename         = "../packages/functions/dist/socket-connect.zip"
  source_code_hash = filebase64sha256("../packages/functions/dist/socket-connect.zip")
  role             = aws_iam_role.socket-connect.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      CONNECTIONS_TABLE = var.connections_table_name,
    }, {})
  }
}

resource "aws_lambda_permission" "socket-connect" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.socket-connect.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.live_scores_execution_arn}/*/$connect"
}

resource "aws_cloudwatch_log_group" "socket-connect" {
  name              = "/aws/lambda/${aws_lambda_function.socket-connect.function_name}"
  retention_in_days = 14
}
