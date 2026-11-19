# rough guide: xs/s for dev, m/l for staging, xl/xxl for production

locals {
  engines = {
    redis = {
      engine_version         = "7.1"
      parameter_group_family = "redis7"
    }
    valkey = {
      engine_version         = "8.1"
      parameter_group_family = "valkey8"
    }
  }

  sizes = {
    # single node, no HA. In cluster mode it gets 1 replica because AWS requires failover there
    xs = {
      node_type          = "cache.t4g.micro"
      replicas           = 0
      replicas_cluster   = 1
      high_availability  = false
      backups            = false
      maintenance_window = null
    }
    s = {
      node_type          = "cache.t4g.small"
      replicas           = 0
      replicas_cluster   = 1
      high_availability  = false
      backups            = false
      maintenance_window = null
    }
    m = {
      node_type          = "cache.t4g.small"
      replicas           = 1
      replicas_cluster   = 1
      high_availability  = true
      backups            = false
      maintenance_window = null
    }
    l = {
      node_type          = "cache.t4g.medium"
      replicas           = 2
      replicas_cluster   = 2
      high_availability  = true
      backups            = false
      maintenance_window = null
    }
    xl = {
      node_type          = "cache.r7g.large"
      replicas           = 2
      replicas_cluster   = 2
      high_availability  = true
      backups            = true
      maintenance_window = "sun:05:00-sun:06:00"
    }
    xxl = {
      node_type          = "cache.r7g.xlarge"
      replicas           = 3
      replicas_cluster   = 2
      high_availability  = true
      backups            = true
      maintenance_window = "sun:05:00-sun:06:00"
    }
  }

  default_parameters = [
    { name = "maxmemory-policy", value = "allkeys-lru" },
    { name = "tcp-keepalive", value = "300" },
  ]

  engine = local.engines[var.engine]
  size   = local.sizes[var.size]

  engine_version = coalesce(var.engine_version_override, local.engine.engine_version)
  node_type      = coalesce(var.node_type_override, local.size.node_type)
  replicas       = coalesce(var.replicas_override, var.cluster_mode ? local.size.replicas_cluster : local.size.replicas)
  ha             = var.cluster_mode || (local.size.high_availability && local.replicas > 0)

  # parameters passed by the caller win over the defaults with the same name
  parameters = concat(
    [for p in local.default_parameters : p if !contains([for c in var.parameters : c.name], p.name)],
    var.parameters,
  )
}
