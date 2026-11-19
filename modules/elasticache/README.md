# elasticache

Redis or Valkey replication group on top of [terraform-aws-modules/elasticache](https://registry.terraform.io/modules/terraform-aws-modules/elasticache/aws). Instead of choosing node types, replicas and backups, you pick a size from [presets.tf](presets.tf).

```hcl
module "sessions" {
  source = "../../modules/elasticache"

  name   = "shop-sessions-prod"
  engine = "valkey"
  size   = "xl"

  vpc_id                     = var.vpc_id
  subnet_ids                 = var.private_subnet_ids
  allowed_security_group_ids = [var.app_security_group_id]
}
```

Notes:

- Encryption in transit and at rest is always on. Clients have to connect with TLS.
- The module creates the security group. You only say who can connect (`allowed_security_group_ids` / `allowed_cidr_blocks`).
- With `cluster_mode = true` the cache is always HA, so even `xs` gets one replica, and the `endpoint` output returns the configuration endpoint.
- Backups and the maintenance window are only set for `xl` and `xxl`.
- `apply_immediately` is false by default: changes wait for the maintenance window unless you ask otherwise.
- Overrides: `engine_version_override`, `node_type_override`, `replicas_override` and `parameters`.

All inputs are in [variables.tf](variables.tf).
