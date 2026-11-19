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
  type = string
}

resource "aws_security_group" "cache" {
  name   = "shop-rate-limiter"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "from_app" {
  security_group_id            = aws_security_group.cache.id
  referenced_security_group_id = var.app_security_group_id
  ip_protocol                  = "tcp"
  # serverless uses 6379 for writes and 6380 for the reader endpoint
  from_port = 6379
  to_port   = 6380
}

module "rate_limiter" {
  source = "../../modules/elasticache-serverless"

  name               = "shop-rate-limiter"
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.cache.id]

  cache_usage_limits = {
    data_storage    = { maximum = 5 }
    ecpu_per_second = { maximum = 5000 }
  }

  daily_snapshot_time = "03:00"

  tags = { team = "shop", environment = "prod" }
}

output "endpoint" {
  value = module.rate_limiter.endpoint
}
