data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # us-east-1 -> use1, sa-east-1 -> sae1, eu-west-2 -> euw2
  region_parts = split("-", data.aws_region.current.region)
  region_short = "${local.region_parts[0]}${substr(local.region_parts[1], 0, 1)}${local.region_parts[2]}"

  env_short = lookup({
    development = "dev"
    staging     = "stg"
    production  = "prod"
  }, var.env, var.env)

  naming_prefix = join("-", [var.owner, local.region_short, var.name, local.env_short])
  name          = var.fifo_topic ? "${local.naming_prefix}.fifo" : local.naming_prefix
}
