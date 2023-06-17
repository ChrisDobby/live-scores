resource "aws_cloudwatch_event_rule" "get-scorecard-urls" {
  name                = "get-scorecard-urls"
  description         = "Triggers get scorecard urls lambda from cloudwatch"
  schedule_expression = "cron(0,30 11,12,13,14 ? APR,MAY,JUN,JUL,AUG,SEP SAT,SUN *)"
}

resource "aws_cloudwatch_event_target" "get-scorecard-urls" {
  rule = aws_cloudwatch_event_rule.get-scorecard-urls.name
  arn  = aws_lambda_function.get-scorecard-urls.arn
}

resource "aws_lambda_permission" "get-scorecard-urls" {
  statement_id  = "invocation-from-cloudwatch-rule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get-scorecard-urls.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.get-scorecard-urls.arn
}
