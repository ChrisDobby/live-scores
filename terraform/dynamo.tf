resource "aws_dynamodb_table" "live-score-urls" {
  name             = "cleckheaton-cc-live-score-urls"
  hash_key         = "date"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "date"
    type = "S"
  }

  ttl {
    attribute_name = "expiry"
    enabled        = true
  }
}

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

resource "aws_dynamodb_table" "live-score-subscriptions" {
  name         = "cleckheaton-cc-live-score-subscriptions"
  hash_key     = "endpoint"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "endpoint"
    type = "S"
  }
}
