resource "aws_lambda_function" "get-scorecard-urls" {
  s3_bucket     = aws_s3_bucket.get-urls-dist.bucket
  s3_key        = aws_s3_object.get-urls-zip.key
  function_name = "get-scorecard-urls"
  handler       = "lib/index.handler"
  role          = aws_iam_role.get-scorecard-urls-role.arn

  runtime     = "nodejs14.x"
  timeout     = 600
  memory_size = 256
}
