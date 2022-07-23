resource "aws_s3_bucket" "scorecards" {
  bucket = "cleckheaton-cc-live-scorecards"
}

resource "aws_s3_bucket_lifecycle_configuration" "scorecards" {
  bucket = aws_s3_bucket.scorecards.bucket
  rule {
    id     = "delete-old-scorecards"
    status = "Enabled"
    expiration {
      days = 1
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "scorecards" {
  bucket = aws_s3_bucket.scorecards.bucket

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_notification" "scorecards" {
  bucket = aws_s3_bucket.scorecards.id

  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    lambda_function_arn = aws_lambda_function.scorecard-updated.arn
  }
}
