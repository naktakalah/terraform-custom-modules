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

  fifo_suffix = var.fifo_queue ? ".fifo" : ""
  name        = "${join("-", [var.owner, local.region_short, var.name, local.env_short])}${local.fifo_suffix}"
  dlq_name    = "${join("-", [var.owner, local.region_short, var.name, "dlq", local.env_short])}${local.fifo_suffix}"

  # SQS managed SSE and a KMS key are mutually exclusive
  sqs_managed_sse = var.kms_master_key_id == null ? var.sqs_managed_sse_enabled : null
}
