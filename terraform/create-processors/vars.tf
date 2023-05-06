variable "html_sqs_url" {
  type = string
}

variable "live_scores_table_arn" {
  type = string
}

variable "live_scores_table_stream_arn" {
  type = string
}

variable "scorecard_processor_role_arn" {
  type = string
}

variable "scorecard_processor_instance_profile_arn" {
  type = string
}

variable "scorecard_processor_security_group_id" {
  type = string
}
