resource "aws_lambda_function" "update-processors" {
  function_name    = "update-processors"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/update-processors.zip"
  source_code_hash = filebase64sha256("../functions/dist/update-processors.zip")
  role             = aws_iam_role.update-processors.arn

  runtime = "nodejs18.x"
  timeout = 10
}

resource "aws_lambda_permission" "update-processors" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update-processors.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.updated_topic_arn
}
