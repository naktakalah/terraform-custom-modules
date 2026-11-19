# One topic, two consumers. Each queue only gets the events it cares about.
#
#                       ┌── filter: order_created ─────────► billing queue ──► billing DLQ
#   orders topic ──────┤
#                       └── filter: order_shipped, ... ────► notifications queue ──► DLQ

provider "aws" {
  region = "us-east-1"
}

locals {
  owner = "shop"
  env   = "dev"
  tags = {
    team        = "shop"
    environment = "dev"
    managed_by  = "terraform"
  }

  consumers = {
    billing       = ["order_created"]
    notifications = ["order_created", "order_shipped", "order_cancelled"]
  }
}

module "orders_topic" {
  source = "../../modules/sns-topic"

  name  = "orders"
  owner = local.owner
  env   = local.env
  tags  = local.tags

  kms_master_key_id = "alias/aws/sns"
}

module "queue" {
  source   = "../../modules/sqs"
  for_each = local.consumers

  name  = each.key
  owner = local.owner
  env   = local.env
  tags  = local.tags

  visibility_timeout_seconds = 60
  create_dlq                 = true
  dlq_max_receive_count      = 5
}

# SNS needs permission to send to each queue
resource "aws_sqs_queue_policy" "allow_topic" {
  for_each = local.consumers

  queue_url = module.queue[each.key].queue_url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowOrdersTopic"
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = module.queue[each.key].queue_arn
      Condition = { ArnEquals = { "aws:SourceArn" = module.orders_topic.topic_arn } }
    }]
  })
}

module "subscription" {
  source   = "../../modules/sns-subscription"
  for_each = local.consumers

  topic_arn = module.orders_topic.topic_arn
  protocol  = "sqs"
  endpoint  = module.queue[each.key].queue_arn

  raw_message_delivery = true
  filter_policy        = { event_type = each.value }

  dlq_arn = module.queue[each.key].dlq_arn
}
