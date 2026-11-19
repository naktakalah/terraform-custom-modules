module "elasticache" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "1.11.0"

  replication_group_id = substr(var.name, 0, 40)
  description          = coalesce(var.description, "${var.engine} ${var.size} - ${var.name}")

  engine         = var.engine
  engine_version = local.engine_version
  node_type      = local.node_type
  port           = var.port

  cluster_mode_enabled    = var.cluster_mode
  num_node_groups         = var.cluster_mode ? var.num_shards : null
  replicas_per_node_group = var.cluster_mode ? local.replicas : null
  # without cluster mode the replicas are expressed as total nodes
  num_cache_clusters = var.cluster_mode ? null : 1 + local.replicas

  automatic_failover_enabled = local.ha
  multi_az_enabled           = local.ha

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  kms_key_arn                = var.kms_key_arn
  user_group_ids             = var.user_group_id != null ? [var.user_group_id] : null

  snapshot_retention_limit = local.size.backups ? var.snapshot_retention_limit : 0
  snapshot_window          = local.size.backups ? var.snapshot_window : null
  maintenance_window       = local.size.maintenance_window

  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = false

  create_parameter_group = true
  parameter_group_name   = "${var.name}-params"
  parameter_group_family = local.engine.parameter_group_family
  parameters             = local.parameters

  subnet_group_name = var.name
  subnet_ids        = var.subnet_ids

  vpc_id                = var.vpc_id
  create_security_group = true
  security_group_name   = var.name
  security_group_rules = merge(
    { for i, sg in var.allowed_security_group_ids : "ingress_sg_${i}" => { referenced_security_group_id = sg, description = "From ${sg}" } },
    { for i, cidr in var.allowed_cidr_blocks : "ingress_cidr_${i}" => { cidr_ipv4 = cidr, description = "From ${cidr}" } },
  )
  security_group_ids = var.security_group_ids

  tags = var.tags
}
