resource "aws_lambda_function" "teardown-processors" {
  function_name    = "teardown-processors"
  handler          = "lib/index.handler"
  filename         = "../../functions/dist/teardown-processors.zip"
  source_code_hash = filebase64sha256("../../functions/dist/teardown-processors.zip")
  role             = aws_iam_role.teardown-processors.arn

  runtime = "nodejs18.x"
  timeout = 10
}
