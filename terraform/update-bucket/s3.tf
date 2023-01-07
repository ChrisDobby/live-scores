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
