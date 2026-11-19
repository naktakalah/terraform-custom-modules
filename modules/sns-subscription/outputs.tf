output "arn" {
  description = "Subscription ARN."
  value       = aws_sns_topic_subscription.this.arn
}

output "owner_id" {
  description = "AWS account that owns the subscription."
  value       = aws_sns_topic_subscription.this.owner_id
}
