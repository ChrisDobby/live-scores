resource "aws_lambda_function" "web-notify" {
  function_name    = "web-notify"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/web-notify.zip"
  source_code_hash = filebase64sha256("../functions/dist/web-notify.zip")
  role             = aws_iam_role.web-notify.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      VAPID_SUBJECT                 = var.vapid_subject,
      VAPID_PUBLIC_KEY              = var.vapid_public_key,
      VAPID_PRIVATE_KEY             = var.vapid_private_key,
      DELETE_SUBSCRIPTION_QUEUE_URL = var.delete_notification_subscription_queue_url
    }, {})
  }
}

resource "aws_lambda_event_source_mapping" "web-notify" {
  event_source_arn = var.sqs_arn
  function_name    = aws_lambda_function.web-notify.function_name
  batch_size       = 10
}

resource "aws_cloudwatch_log_group" "web-notify" {
  name              = "/aws/lambda/${aws_lambda_function.web-notify.function_name}"
  retention_in_days = 14
}
