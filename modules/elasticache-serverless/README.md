# elasticache-serverless

ElastiCache Serverless (Valkey by default) on top of the `serverless-cache` submodule of [terraform-aws-modules/elasticache](https://registry.terraform.io/modules/terraform-aws-modules/elasticache/aws). Good for caches with spiky or unknown traffic, where sizing nodes is guesswork.

```hcl
module "rate_limiter" {
  source = "../../modules/elasticache-serverless"

  name               = "shop-rate-limiter"
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.cache.id]

  cache_usage_limits = {
    data_storage    = { maximum = 5 }
    ecpu_per_second = { maximum = 5000 }
  }
}
```

Notes:

- Set `cache_usage_limits`. Without them the cache scales (and bills) without a ceiling.
- The security group must allow 6379 and 6380 (reader endpoint).
- The upstream module takes the limits as `map(any)`, so the module normalizes them first. Otherwise passing only `data_storage` or only `ecpu_per_second` fails with a type error.

All inputs are in [variables.tf](variables.tf).
