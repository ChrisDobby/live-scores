variable "push_topic_arn" {
  type = string
}

variable "vapid_subject" {
  type = string
}

variable "vapid_public_key" {
  type = string
}

variable "vapid_private_key" {
  type = string
}

variable "subscriptions_table_arn" {
  type = string
}

variable "sqs_arn" {
  type = string
}

variable "delete_notification_subscription_queue_url" {
  type = string
}

variable "delete_notification_subscription_queue_arn" {
  type = string
}
