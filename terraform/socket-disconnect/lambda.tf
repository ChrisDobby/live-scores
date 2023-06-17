resource "aws_lambda_function" "socket-disconnect" {
  function_name    = "socket-disconnect"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/socket-disconnect.zip"
  source_code_hash = filebase64sha256("../functions/dist/socket-disconnect.zip")
  role             = aws_iam_role.socket-disconnect.arn

  runtime = "nodejs18.x"
  timeout = 10
}

resource "aws_lambda_permission" "socket-disconnect" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.socket-disconnect.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.live_scores_execution_arn}/*/$disconnect"
}

resource "aws_cloudwatch_log_group" "socket-disconnect" {
  name              = "/aws/lambda/${aws_lambda_function.socket-disconnect.function_name}"
  retention_in_days = 14
}
