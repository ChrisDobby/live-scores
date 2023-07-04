resource "aws_sfn_state_machine" "restart-processor" {
  name     = "my-state-machine"
  role_arn = aws_iam_role.restart-processor.arn
  type     = "EXPRESS"

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
