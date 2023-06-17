resource "aws_lambda_function" "api-authoriser" {
  function_name    = "api-authoriser"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/api-authoriser.zip"
  source_code_hash = filebase64sha256("../functions/dist/api-authoriser.zip")
  role             = aws_iam_role.api-authoriser.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      API_KEY = var.api_key
    }, {})
  }
}

resource "aws_lambda_permission" "api-authoriser" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api-authoriser.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.notifications_execution_arn}/authorizers/${var.notifications_authoriser_id}"
}

resource "aws_cloudwatch_log_group" "api-authoriser" {
  name              = "/aws/lambda/${aws_lambda_function.api-authoriser.function_name}"
  retention_in_days = 14
}
