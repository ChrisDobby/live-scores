// push notification registration
resource "aws_apigatewayv2_api" "notifications" {
  name          = "cleckheaton-notifications"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["*"]
    allow_methods = ["POST"]
    allow_origins = ["https://cleckheatoncricketclub.org.uk"]
  }
}

resource "aws_apigatewayv2_integration" "notifications-subscribe" {
  api_id           = aws_apigatewayv2_api.notifications.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  integration_uri      = module.subscribe-to-scores.invoke_arn
  integration_method   = "POST"
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "notifications-subscribe" {
  api_id             = aws_apigatewayv2_api.notifications.id
  route_key          = "POST /"
  target             = "integrations/${aws_apigatewayv2_integration.notifications-subscribe.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.notifications.id
}

resource "aws_apigatewayv2_integration" "notifications-unsubscribe" {
  api_id           = aws_apigatewayv2_api.notifications.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  integration_uri      = module.subscribe-to-scores.invoke_arn
  integration_method   = "POST"
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "notifications-unsubscribe" {
  api_id             = aws_apigatewayv2_api.notifications.id
  route_key          = "DELETE /{endpoint}"
  target             = "integrations/${aws_apigatewayv2_integration.notifications-unsubscribe.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.notifications.id
}


resource "aws_apigatewayv2_integration" "notifications-update" {
  api_id           = aws_apigatewayv2_api.notifications.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  integration_uri      = module.subscribe-to-scores.invoke_arn
  integration_method   = "POST"
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "notifications-update" {
  api_id             = aws_apigatewayv2_api.notifications.id
  route_key          = "PUT /"
  target             = "integrations/${aws_apigatewayv2_integration.notifications-update.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.notifications.id
}

resource "aws_apigatewayv2_stage" "notifications-prod" {
  api_id = aws_apigatewayv2_api.notifications.id
  name   = "prod"
}

resource "aws_apigatewayv2_authorizer" "notifications" {
  api_id                            = aws_apigatewayv2_api.notifications.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = module.api_authoriser.invoke_arn
  name                              = "notifications-authoriser"
  identity_sources                  = ["$request.header.Authorization"]
  enable_simple_responses           = true
  authorizer_payload_format_version = "2.0"
}

resource "aws_apigatewayv2_deployment" "notifications" {
  api_id = aws_apigatewayv2_api.notifications.id

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_api.notifications),
      jsonencode(aws_apigatewayv2_integration.notifications-subscribe),
      jsonencode(aws_apigatewayv2_route.notifications-subscribe),
      jsonencode(aws_apigatewayv2_integration.notifications-unsubscribe),
      jsonencode(aws_apigatewayv2_route.notifications-unsubscribe),
      jsonencode(aws_apigatewayv2_integration.notifications-update),
      jsonencode(aws_apigatewayv2_authorizer.notifications),
      jsonencode(aws_apigatewayv2_route.notifications-update),
      jsonencode(aws_apigatewayv2_stage.notifications-prod),
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }
}
