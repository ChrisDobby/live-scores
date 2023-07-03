resource "aws_lambda_function" "initialise-restarts" {
  function_name    = "initialise-restarts"
  handler          = "lib/index.handler"
  filename         = "../packages/functions/dist/initialise-restarts.zip"
  source_code_hash = filebase64sha256("../packages/functions/dist/initialise-restarts.zip")
  role             = aws_iam_role.initialise-restarts.arn

  runtime = "nodejs18.x"
  timeout = 10

  environment {
    variables = merge({
      RESTART_SCHEDULE_QUEUE_URL = var.restart_schedule_queue_url,
    }, {})
  }
}

resource "aws_lambda_function_event_invoke_config" "initialise-restarts" {
  function_name          = aws_lambda_function.initialise-restarts.function_name
  qualifier              = "$LATEST"
  maximum_retry_attempts = 0
}

resource "aws_lambda_event_source_mapping" "initialise-restarts" {
  event_source_arn       = var.live_scores_table_stream_arn
  function_name          = aws_lambda_function.initialise-restarts.arn
  starting_position      = "LATEST"
  batch_size             = 1
  maximum_retry_attempts = 2
}

resource "aws_cloudwatch_log_group" "initialise-restarts" {
  name              = "/aws/lambda/${aws_lambda_function.initialise-restarts.function_name}"
  retention_in_days = 14
}
