resource "aws_dynamodb_table" "live-score-connections" {
  name         = "cleckheaton-cc-live-score-connections"
  hash_key     = "connectionId"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "connectionId"
    type = "S"
  }

  ttl {
    attribute_name = "expiry"
    enabled        = true
  }
}
