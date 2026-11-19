output "replication_group_id" {
  description = "Replication group ID."
  value       = module.elasticache.replication_group_id
}

output "arn" {
  description = "Replication group ARN."
  value       = module.elasticache.replication_group_arn
}

output "endpoint" {
  description = "Endpoint to connect to: configuration endpoint in cluster mode, primary endpoint otherwise."
  value       = var.cluster_mode ? module.elasticache.replication_group_configuration_endpoint_address : module.elasticache.replication_group_primary_endpoint_address
}

output "reader_endpoint" {
  description = "Reader endpoint (not available in cluster mode)."
  value       = var.cluster_mode ? null : module.elasticache.replication_group_reader_endpoint_address
}

output "port" {
  description = "Port."
  value       = var.port
}

output "security_group_id" {
  description = "Security group created for the cache."
  value       = module.elasticache.security_group_id
}

output "settings" {
  description = "Resolved settings (preset + overrides), handy to check what a size means."
  value = {
    engine_version    = local.engine_version
    node_type         = local.node_type
    replicas          = local.replicas
    high_availability = local.ha
    backups           = local.size.backups
  }
}
