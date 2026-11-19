output "arn" {
  description = "Serverless cache ARN."
  value       = module.elasticache.serverless_cache_arn
}

output "endpoint" {
  description = "Endpoint (address and port)."
  value       = module.elasticache.serverless_cache_endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint (address and port)."
  value       = module.elasticache.serverless_cache_reader_endpoint
}
