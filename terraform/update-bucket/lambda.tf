resource "aws_lambda_function" "update-bucket" {
  function_name    = "update-bucket"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/update-bucket.zip"
  source_code_hash = filebase64sha256("../../functions/dist/update-bucket.zip")
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
