resource "aws_lambda_function" "push-notify" {
  function_name    = "push-notify"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/push-notify.zip"
  source_code_hash = filebase64sha256("../functions/dist/push-notify.zip")
  role             = aws_iam_role.push-notify.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      PUSH_NOTIFY_BUCKET_NAME = aws_s3_bucket.notifications.bucket,
      PUSH_TOPIC_ARN          = var.push_topic_arn,
    }, {})
  }
}

resource "aws_lambda_permission" "push-notify" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.push-notify.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.updated_topic_arn
}

resource "aws_cloudwatch_log_group" "push-notify" {
  name              = "/aws/lambda/${aws_lambda_function.push-notify.function_name}"
  retention_in_days = 14
}
