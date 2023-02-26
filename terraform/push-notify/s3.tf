resource "aws_s3_bucket" "notifications" {
  bucket = "cleckheaton-cc-notifications"
}

resource "aws_s3_bucket_lifecycle_configuration" "notifications" {
  bucket = aws_s3_bucket.notifications.bucket
  rule {
    id     = "delete-old-notifications"
    status = "Enabled"
    expiration {
      days = 1
    }
  }
}
