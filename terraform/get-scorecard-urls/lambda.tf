resource "aws_lambda_function" "get-scorecard-urls" {
  function_name    = "get-scorecard-urls"
  handler          = "lib/index.handler"
  filename         = "../functions/dist/get-scorecard-urls.zip"
  source_code_hash = filebase64sha256("../functions/dist/get-scorecard-urls.zip")
  role             = aws_iam_role.get-scorecard-urls.arn

  runtime     = "nodejs14.x"
  timeout     = 600
  memory_size = 256

  layers = ["arn:aws:lambda:eu-west-2:604776666101:layer:chrome-aws-lambda:1"]
}
