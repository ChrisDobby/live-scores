module "get-scorecard-urls" {
  source = "./get-scorecard-urls"

  live_scores_table_arn = aws_dynamodb_table.live-score-urls.arn
}

module "create-processors" {
  source = "./create-processors"

  first_team_sqs_url                       = aws_sqs_queue.first-team-scorecard-html.url
  second_team_sqs_url                      = aws_sqs_queue.second-team-scorecard-html.url
  live_scores_table_arn                    = aws_dynamodb_table.live-score-urls.arn
  live_scores_table_stream_arn             = aws_dynamodb_table.live-score-urls.stream_arn
  scorecard_processor_instance_profile_arn = module.scorecard-processor.scorecard_processor_instance_profile_arn
  scorecard_processor_role_arn             = module.scorecard-processor.scorecard_processor_role_arn
  scorecard_processor_security_group_id    = aws_security_group.allow_ssh.id
}

module "teardown-processors" {
  source = "./teardown-processors"
}

module "scorecard-processor" {
  source = "./scorecard-processor"

  first_team_sqs_arn  = aws_sqs_queue.first-team-scorecard-html.arn
  second_team_sqs_arn = aws_sqs_queue.second-team-scorecard-html.arn
}

module "create-scorecard" {
  source = "./create-scorecard"

  first_team_sqs_arn  = aws_sqs_queue.first-team-scorecard-html.arn
  second_team_sqs_arn = aws_sqs_queue.second-team-scorecard-html.arn
  updated_topic_arn   = aws_sns_topic.scorecard-updated.arn
}

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

module "update-bucket" {
  source = "./update-bucket"

  updated_topic_arn = aws_sns_topic.scorecard-updated.arn
}

module "update-processors" {
  source = "./update-processors"

  updated_topic_arn = aws_sns_topic.scorecard-updated.arn
}

module "update-sanity" {
  source = "./update-sanity"

  updated_topic_arn     = aws_sns_topic.scorecard-updated.arn
  sanity_auth_token     = var.SANITY_AUTH_TOKEN
  live_scores_table_arn = aws_dynamodb_table.live-score-urls.arn
}

module "update-sockets" {
  source = "./update-sockets"

  updated_topic_arn         = aws_sns_topic.scorecard-updated.arn
  invoke_url                = aws_apigatewayv2_stage.live-scores-prod.invoke_url
  connections_table_arn     = aws_dynamodb_table.live-score-connections.arn
  live_scores_execution_arn = aws_apigatewayv2_api.live-scores.execution_arn
  live_scores_api_name      = aws_apigatewayv2_stage.live-scores-prod.name
}

module "push-notify" {
  source = "./push-notify"

  updated_topic_arn = aws_sns_topic.scorecard-updated.arn
  push_topic_arn    = aws_sns_topic.push-notification.arn
}

module "subscribe-to-scores" {
  source = "./subscribe-to-scores"

  notifications_execution_arn = aws_apigatewayv2_api.notifications.execution_arn
  subscriptions_table_arn     = aws_dynamodb_table.live-score-subscriptions.arn
  web_notify_queue_url        = aws_sqs_queue.web-notify.url
  web_notify_queue_arn        = aws_sqs_queue.web-notify.arn

  delete_notification_subscription_queue_url        = aws_sqs_queue.delete-notification-subscription.url
  delete_notification_subscription_queue_arn        = aws_sqs_queue.delete-notification-subscription.arn
}

module "web-notify" {
  source = "./web-notify"

  push_topic_arn                                    = aws_sns_topic.push-notification.arn
  subscriptions_table_arn                           = aws_dynamodb_table.live-score-subscriptions.arn
  vapid_subject                                     = var.VAPID_SUBJECT
  vapid_public_key                                  = var.VAPID_PUBLIC_KEY
  vapid_private_key                                 = var.VAPID_PRIVATE_KEY
  sqs_arn                                           = aws_sqs_queue.web-notify.arn
  delete_notification_subscription_queue_url        = aws_sqs_queue.delete-notification-subscription.url
  delete_notification_subscription_queue_arn        = aws_sqs_queue.delete-notification-subscription.arn
}

module "api_authoriser" {
  source = "./api-authoriser"

  notifications_execution_arn = aws_apigatewayv2_api.notifications.execution_arn
  notifications_authoriser_id = aws_apigatewayv2_authorizer.notifications.id
  api_key                     = var.API_KEY
}

module "delete-web-subscription" {
  source = "./delete-web-subscription"

  subscriptions_table_arn                           = aws_dynamodb_table.live-score-subscriptions.arn
  sqs_arn                                           = aws_sqs_queue.delete-notification-subscription.arn
}
