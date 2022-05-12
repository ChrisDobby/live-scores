resource "aws_s3_bucket" "get-urls-dist" {
  bucket = "cleckheaton-cc-get-scorecard-urls-dist"
}

resource "aws_s3_object" "get-urls-zip" {
  bucket = aws_s3_bucket.get-urls-dist.bucket
  key    = "get-scorecard-urls.zip"
  source = "../functions/dist/get-scorecard-urls.zip"
}

resource "aws_s3_bucket" "live-scores-html" {
  bucket = "cleckheaton-cc-live-scores-html"
}
