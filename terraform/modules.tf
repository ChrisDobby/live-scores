module "socket-connect" {
  source = "./socket-connect"

  live_scores_execution_arn = aws_apigatewayv2_api.live-scores.execution_arn
  connections_table_arn     = aws_dynamodb_table.live-score-connections.arn
}

module "socket-disconnect" {
  source = "./socket-disconnect"

  live_scores_execution_arn = aws_apigatewayv2_api.live-scores.execution_arn
  connections_table_arn     = aws_dynamodb_table.live-score-connections.arn
}

module "update-sockets" {
  source = "./update-sockets"

  updated_topic_arn         = aws_sns_topic.scorecard-updated.arn
  invoke_url                = aws_apigatewayv2_stage.live-scores-prod.invoke_url
  connections_table_arn     = aws_dynamodb_table.live-score-connections.arn
  live_scores_execution_arn = aws_apigatewayv2_api.live-scores.execution_arn
  live_scores_api_name      = aws_apigatewayv2_stage.live-scores-prod.name
}
