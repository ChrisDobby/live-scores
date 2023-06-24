module "get-scorecard-urls" {
  source = "./get-scorecard-urls"

  live_scores_table_arn = aws_dynamodb_table.live-score-urls.arn
}

module "create-processors" {
  source = "./create-processors"

  html_sqs_url                             = aws_sqs_queue.scorecard-html.url
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

  html_sqs_arn = aws_sqs_queue.scorecard-html.arn
}
