resource "aws_apigatewayv2_api" "live-scores" {
  name                       = "cleckheaton-live-scores"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_integration" "live-scores-connect" {
  api_id           = aws_apigatewayv2_api.live-scores.id
  integration_type = "AWS"

  connection_type           = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  integration_uri           = aws_lambda_function.socket-connect.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_integration" "live-scores-disconnect" {
  api_id           = aws_apigatewayv2_api.live-scores.id
  integration_type = "MOCK"
}

resource "aws_apigatewayv2_route" "live-scores-connect" {
  api_id    = aws_apigatewayv2_api.live-scores.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.live-scores-connect.id}"
}

resource "aws_apigatewayv2_route" "live-scores-disconnect" {
  api_id    = aws_apigatewayv2_api.live-scores.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.live-scores-disconnect.id}"
}

resource "aws_apigatewayv2_stage" "live-scores-prod" {
  api_id = aws_apigatewayv2_api.live-scores.id
  name   = "prod"
}
