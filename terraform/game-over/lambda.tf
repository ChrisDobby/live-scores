resource "aws_lambda_function" "game-over" {
  function_name    = "game-over"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/game-over.zip"
  source_code_hash = filebase64sha256("../functions/dist/game-over.zip")
  role             = aws_iam_role.game-over.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      GAME_OVER_TOPIC_ARN = var.game_over_topic_arn,
    }, {})
  }
}

resource "aws_lambda_permission" "game-over" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.game-over.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.updated_topic_arn
}

resource "aws_cloudwatch_log_group" "game-over" {
  name              = "/aws/lambda/${aws_lambda_function.game-over.function_name}"
  retention_in_days = 14
}
