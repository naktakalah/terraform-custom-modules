output "topic_arn" {
  description = "Topic ARN."
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "Topic name."
  value       = aws_sns_topic.this.name
}

output "topic_owner" {
  description = "AWS account that owns the topic."
  value       = aws_sns_topic.this.owner
}

output "success_role_arn" {
  description = "IAM role used to log successful deliveries."
  value       = local.success_role_arn
}

output "failure_role_arn" {
  description = "IAM role used to log failed deliveries."
  value       = local.failure_role_arn
}
