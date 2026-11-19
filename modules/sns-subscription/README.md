# sns-subscription

Subscribes an endpoint (usually an SQS queue or a Lambda) to a topic.

```hcl
module "billing_subscription" {
  source = "../../modules/sns-subscription"

  topic_arn = module.orders_topic.topic_arn
  protocol  = "sqs"
  endpoint  = module.billing_queue.queue_arn

  raw_message_delivery = true
  filter_policy        = { event_type = ["order_created"] }

  dlq_arn = module.billing_queue.dlq_arn
}
```

Notes:

- `filter_policy` is a plain HCL object, the module encodes it.
- With `raw_message_delivery` the consumer gets the original message instead of the SNS JSON envelope, which saves every consumer from unwrapping it.
- `dlq_arn` catches messages SNS couldn't deliver at all (for example, when the queue policy doesn't allow the topic). It's different from the queue's own DLQ, which catches messages the consumer failed to process.
- For SQS, the queue still needs a policy that allows `sqs:SendMessage` from the topic. See [examples/sns-sqs-fanout](../../examples/sns-sqs-fanout).

All inputs are in [variables.tf](variables.tf).
