resource "aws_lambda_function" "update-bucket" {
  function_name    = "update-bucket"
  handler          = "lib/index.handler"
  filename         = "../packages/functions/dist/update-bucket.zip"
  source_code_hash = filebase64sha256("../packages/functions/dist/update-bucket.zip")
  role             = aws_iam_role.update-bucket.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      SCORECARD_BUCKET_NAME = aws_s3_bucket.scorecards.bucket,
    }, {})
  }
}

resource "aws_lambda_permission" "update-bucket" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update-bucket.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.updated_topic_arn
}

resource "aws_cloudwatch_log_group" "update-bucket" {
  name              = "/aws/lambda/${aws_lambda_function.update-bucket.function_name}"
  retention_in_days = 14
}
