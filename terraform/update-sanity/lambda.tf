resource "aws_lambda_function" "update-sanity" {
  function_name    = "update-sanity"
  handler          = "lib/index.handler"
  filename         = "../packages/functions/dist/update-sanity.zip"
  source_code_hash = filebase64sha256("../packages/functions/dist/update-sanity.zip")
  role             = aws_iam_role.update-sanity.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      SANITY_AUTH_TOKEN = var.sanity_auth_token,
    }, {})
  }
}

resource "aws_lambda_permission" "update-sanity" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update-sanity.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.game_over_topic_arn
}

resource "aws_cloudwatch_log_group" "update-sanity" {
  name              = "/aws/lambda/${aws_lambda_function.update-sanity.function_name}"
  retention_in_days = 14
}
