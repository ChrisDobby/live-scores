module "create-scorecard" {
  source = "./create-scorecard"

  html_sqs_arn      = aws_sqs_queue.scorecard-html.arn
  updated_topic_arn = aws_sns_topic.scorecard-updated.arn
}

module "update-bucket" {
  source = "./update-bucket"

  updated_topic_arn = aws_sns_topic.scorecard-updated.arn
}

module "update-processors" {
  source = "./update-processors"

  game_over_topic_arn = aws_sns_topic.game-over.arn
}

module "update-sanity" {
  source = "./update-sanity"

  game_over_topic_arn   = aws_sns_topic.game-over.arn
  sanity_auth_token     = var.SANITY_AUTH_TOKEN
  live_scores_table_arn = aws_dynamodb_table.live-score-urls.arn
}

module "game-over" {
  source = "./game-over"

  updated_topic_arn   = aws_sns_topic.scorecard-updated.arn
  game_over_topic_arn = aws_sns_topic.game-over.arn
}

