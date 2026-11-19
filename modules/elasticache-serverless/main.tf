locals {
  major_engine_version = coalesce(var.major_engine_version, var.engine == "valkey" ? "8" : "7")

  # upstream takes map(any): both objects need the same shape and unset ones must go
  usage_limits = {
    for k, v in {
      data_storage = var.cache_usage_limits.data_storage == null ? null : {
        maximum = var.cache_usage_limits.data_storage.maximum
        minimum = var.cache_usage_limits.data_storage.minimum
        unit    = var.cache_usage_limits.data_storage.unit
      }
      ecpu_per_second = var.cache_usage_limits.ecpu_per_second == null ? null : {
        maximum = var.cache_usage_limits.ecpu_per_second.maximum
        minimum = var.cache_usage_limits.ecpu_per_second.minimum
        unit    = null
      }
    } : k => v if v != null
  }
}

module "elasticache" {
  source  = "terraform-aws-modules/elasticache/aws//modules/serverless-cache"
  version = "1.11.0"

  cache_name           = var.name
  description          = var.description
  engine               = var.engine
  major_engine_version = local.major_engine_version

  cache_usage_limits = local.usage_limits

  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  kms_key_id         = var.kms_key_arn
  user_group_id      = var.user_group_id

  daily_snapshot_time      = var.daily_snapshot_time
  snapshot_retention_limit = var.snapshot_retention_limit

  tags = var.tags
}
