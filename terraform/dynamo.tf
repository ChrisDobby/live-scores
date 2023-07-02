resource "aws_dynamodb_table" "live-score-subscriptions" {
  name         = "cleckheaton-cc-live-score-subscriptions"
  hash_key     = "endpoint"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "endpoint"
    type = "S"
  }
}
