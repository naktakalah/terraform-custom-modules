output "topic_arn" {
  value = module.orders_topic.topic_arn
}

output "queue_urls" {
  value = { for k, q in module.queue : k => q.queue_url }
}
