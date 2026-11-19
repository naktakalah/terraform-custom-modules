provider "aws" {
  region = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_security_group_id" {
  description = "SG of whatever connects to the cache (EKS nodes, ECS service...)."
  type        = string
}

# dev: one node, no HA, no backups
module "sessions_dev" {
  source = "../../modules/elasticache"

  name   = "shop-sessions-dev"
  engine = "valkey"
  size   = "xs"

  vpc_id                     = var.vpc_id
  subnet_ids                 = var.private_subnet_ids
  allowed_security_group_ids = [var.app_security_group_id]

  tags = { team = "shop", environment = "dev" }
}

# prod: cluster mode with 2 shards, multi-AZ, daily snapshots
module "catalog_prod" {
  source = "../../modules/elasticache"

  name         = "shop-catalog-prod"
  engine       = "valkey"
  size         = "xl"
  cluster_mode = true
  num_shards   = 2

  vpc_id                     = var.vpc_id
  subnet_ids                 = var.private_subnet_ids
  allowed_security_group_ids = [var.app_security_group_id]

  parameters = [
    { name = "maxmemory-policy", value = "volatile-lru" },
  ]

  tags = { team = "shop", environment = "prod" }
}

output "sessions_dev" {
  value = {
    endpoint = module.sessions_dev.endpoint
    settings = module.sessions_dev.settings
  }
}

output "catalog_prod" {
  value = {
    endpoint = module.catalog_prod.endpoint
    settings = module.catalog_prod.settings
  }
}
