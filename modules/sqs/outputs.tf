output "queue_arn" {
  description = "Queue ARN."
  value       = aws_sqs_queue.this.arn
}

output "queue_url" {
  description = "Queue URL."
  value       = aws_sqs_queue.this.url
}

output "queue_name" {
  description = "Queue name."
  value       = aws_sqs_queue.this.name
}

output "dlq_arn" {
  description = "DLQ ARN."
  value       = try(aws_sqs_queue.dlq[0].arn, null)
}

output "dlq_url" {
  description = "DLQ URL."
  value       = try(aws_sqs_queue.dlq[0].url, null)
}

output "event_source_mappings" {
  description = "UUID and state of each event source mapping."
  value = {
    for k, v in aws_lambda_event_source_mapping.this : k => {
      uuid  = v.uuid
      state = v.state
    }
  }
}
