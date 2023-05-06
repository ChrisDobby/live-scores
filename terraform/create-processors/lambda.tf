resource "aws_lambda_function" "create-processors" {
  function_name    = "create-processors"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/create-processors.zip"
  source_code_hash = filebase64sha256("../functions/dist/create-processors.zip")
  role             = aws_iam_role.create-processors.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      PROCESSOR_PROFILE_ARN = var.scorecard_processor_instance_profile_arn
      PROCESSOR_SG_ID       = var.scorecard_processor_security_group_id,
      PROCESSOR_QUEUE_URL   = var.html_sqs_url,
    }, {})
  }
}

resource "aws_lambda_function_event_invoke_config" "create-processors" {
  function_name          = aws_lambda_function.create-processors.function_name
  qualifier              = "$LATEST"
  maximum_retry_attempts = 0
}

resource "aws_lambda_event_source_mapping" "create-processors" {
  event_source_arn       = var.live_scores_table_stream_arn
  function_name          = aws_lambda_function.create-processors.arn
  starting_position      = "LATEST"
  batch_size             = 1
  maximum_retry_attempts = 2
}

resource "aws_cloudwatch_log_group" "create-processors" {
  name              = "/aws/lambda/${aws_lambda_function.create-processors.function_name}"
  retention_in_days = 14
}
