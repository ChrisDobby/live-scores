output "scorecard_processor_instance_profile_arn" {
  value = aws_iam_instance_profile.scorecard-processor.arn
}

output "scorecard_processor_role_arn" {
  value = aws_iam_role.scorecard-processor.arn
}
