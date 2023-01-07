
resource "aws_cloudwatch_event_rule" "teardown-processors" {
  name                = "teardown-processors"
  description         = "Triggers teardown processors lambda from cloudwatch"
  schedule_expression = "cron(0 21 ? APR,MAY,JUN,JUL,AUG,SEP SAT,SUN *)"
}

resource "aws_cloudwatch_event_target" "teardown-processors" {
  rule = aws_cloudwatch_event_rule.teardown-processors.name
  arn  = aws_lambda_function.teardown-processors.arn
}

resource "aws_lambda_permission" "teardown-processors" {
  statement_id  = "teardown-invocation-from-cloudwatch-rule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.teardown-processors.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.teardown-processors.arn
}
