mock_provider "aws" {}
mock_provider "random" {}

variables {
  name       = "shop-sessions"
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-aaaa1111", "subnet-bbbb2222"]
}

run "xs_is_a_single_node" {
  command = plan

  assert {
    condition     = output.settings.replicas == 0 && !output.settings.high_availability
    error_message = "xs should be one node without HA"
  }

  assert {
    condition     = output.settings.node_type == "cache.t4g.micro" && output.settings.engine_version == "8.1"
    error_message = "unexpected node type or engine version"
  }
}

run "xs_in_cluster_mode_gets_a_replica" {
  command = plan

  variables {
    cluster_mode = true
  }

  assert {
    condition     = output.settings.replicas == 1 && output.settings.high_availability
    error_message = "cluster mode needs failover, so at least one replica"
  }
}

run "xl_has_ha_and_backups" {
  command = plan

  variables {
    engine = "redis"
    size   = "xl"
  }

  assert {
    condition     = output.settings.high_availability && output.settings.backups && output.settings.replicas == 2
    error_message = "xl should be HA with backups"
  }

  assert {
    condition     = output.settings.engine_version == "7.1"
    error_message = "redis should use the redis engine version"
  }
}

run "overrides_win_over_presets" {
  command = plan

  variables {
    size               = "m"
    node_type_override = "cache.m7g.large"
    replicas_override  = 0
  }

  assert {
    condition     = output.settings.node_type == "cache.m7g.large"
    error_message = "node_type_override ignored"
  }

  assert {
    condition     = output.settings.replicas == 0 && !output.settings.high_availability
    error_message = "without replicas there's nothing to fail over to"
  }
}

run "rejects_unknown_size" {
  command = plan

  variables {
    size = "huge"
  }

  expect_failures = [var.size]
}
