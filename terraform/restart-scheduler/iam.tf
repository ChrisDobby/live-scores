data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "restart-scheduler" {
  name               = "restart-scheduler"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.restart-scheduler.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "sqs" {
  name   = "restart-scheduler-sqs"
  policy = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      var.restart_schedule_queue_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.restart-scheduler.name
  policy_arn = aws_iam_policy.sqs.arn
}

resource "aws_iam_policy" "scheduler" {
  name   = "restart-scheduler-scheduler"
  policy = data.aws_iam_policy_document.scheduler.json
}

data "aws_iam_policy_document" "scheduler" {
  statement {
    actions = [
      "scheduler:CreateSchedule",
      "scheduler:CreateScheduleGroup",
      "scheduler:ListScheduleGroups",
      "scheduler:ListSchedules",
      "scheduler:DeleteSchedule",
      "scheduler:DeleteScheduleGroup"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "scheduler" {
  role       = aws_iam_role.restart-scheduler.name
  policy_arn = aws_iam_policy.scheduler.arn
}

resource "aws_iam_policy" "iam" {
  name   = "restart-scheduler-iam"
  policy = data.aws_iam_policy_document.iam.json
}

data "aws_iam_policy_document" "iam" {
  statement {
    actions = ["iam:GetRole", "iam:PassRole"]

    resources = [
      aws_iam_role.scheduler-invoke.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "iam" {
  role       = aws_iam_role.restart-scheduler.name
  policy_arn = aws_iam_policy.iam.arn
}

data "aws_iam_policy_document" "schedule-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "scheduler-invoke" {
  name               = "scheduler-invoke"
  assume_role_policy = data.aws_iam_policy_document.schedule-assume-role.json
}

resource "aws_iam_policy" "state-machine" {
  name   = "scheduler-invoke-state-machine"
  policy = data.aws_iam_policy_document.state-machine.json
}

data "aws_iam_policy_document" "state-machine" {
  statement {
    actions = ["states:StartExecution"]

    resources = [
      var.restart_processor_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "state-machine" {
  role       = aws_iam_role.scheduler-invoke.name
  policy_arn = aws_iam_policy.state-machine.arn
}
