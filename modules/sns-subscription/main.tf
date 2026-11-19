resource "aws_sns_topic_subscription" "this" {
  topic_arn = var.topic_arn
  protocol  = var.protocol
  endpoint  = var.endpoint

  raw_message_delivery            = var.raw_message_delivery
  endpoint_auto_confirms          = var.endpoint_auto_confirms
  confirmation_timeout_in_minutes = var.confirmation_timeout_in_minutes

  filter_policy       = var.filter_policy != null ? jsonencode(var.filter_policy) : null
  filter_policy_scope = var.filter_policy != null ? var.filter_policy_scope : null

  redrive_policy = var.dlq_arn != null ? jsonencode({ deadLetterTargetArn = var.dlq_arn }) : null
}
