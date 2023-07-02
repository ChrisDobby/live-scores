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
