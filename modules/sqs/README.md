# sqs

Creates an SQS queue named `<owner>-<region>-<name>-<env>`, an optional dead-letter queue and Lambda triggers.

```hcl
module "billing_queue" {
  source = "../../modules/sqs"

  name  = "billing"
  owner = "shop"
  env   = "prod"

  visibility_timeout_seconds = 180 # 6x the Lambda timeout
  create_dlq                 = true
  dlq_max_receive_count      = 5

  event_source_mappings = {
    processor = {
      function_name              = "billing-processor"
      batch_size                 = 10
      maximum_concurrency        = 20
      report_batch_item_failures = true
    }
  }
}
```

Notes:

- The DLQ keeps messages for 14 days and only accepts messages from its own queue (`redrive_allow_policy`).
- Encryption is on by default with SQS managed keys. If you pass `kms_master_key_id`, whoever sends messages (SNS, EventBridge...) needs `kms:GenerateDataKey` and `kms:Decrypt` on that key. It's the most common reason for messages silently not arriving.
- Long polling (`receive_wait_time_seconds = 20`) is the default because it cuts empty receives and cost.
- `report_batch_item_failures` lets the function return only the failed messages instead of retrying the whole batch.

All inputs are in [variables.tf](variables.tf).
