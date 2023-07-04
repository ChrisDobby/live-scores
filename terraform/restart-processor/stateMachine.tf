resource "aws_sfn_state_machine" "restart-processor" {
  name     = "restart-processor"
  role_arn = aws_iam_role.restart-processor.arn
  type     = "EXPRESS"

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.restart-processor.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  definition = <<EOF
{
  "Comment": "Restarts the scorecard processor",
  "StartAt": "Parallel",
  "States": {
    "Parallel": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "Teardown existing processor",
          "States": {
            "Teardown existing processor": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "OutputPath": "$.Payload",
              "Parameters": {
                "Payload.$": "$",
                "FunctionName": "${var.teardown_processors_arn}:$LATEST"
              },
              "Retry": [
                {
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException",
                    "Lambda.TooManyRequestsException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "End": true
            }
          }
        },
        {
          "StartAt": "DeleteURLs",
          "States": {
            "DeleteURLs": {
              "Type": "Task",
              "Resource": "arn:aws:states:::dynamodb:deleteItem",
              "Parameters": {
                "TableName": "${var.live_scores_table_name}",
                "Key": {
                  "date": {
                    "S.$": "$.date"
                  }
                }
              },
              "Next": "Get scorecard URLs"
            },
            "Get scorecard URLs": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "OutputPath": "$.Payload",
              "Parameters": {
                "Payload.$": "$",
                "FunctionName": "${var.get_scorecard_urls_arn}:$LATEST"
              },
              "Retry": [
                {
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException",
                    "Lambda.TooManyRequestsException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "End": true
            }
          }
        }
      ],
      "End": true
    }
  }
}
EOF
}

resource "aws_cloudwatch_log_group" "restart-processor" {
  name              = "//aws/vendedlogs/states/restart-processor-logs"
  retention_in_days = 14
}
