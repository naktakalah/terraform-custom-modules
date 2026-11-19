# sns-topic

Creates an SNS topic named `<owner>-<region>-<name>-<env>`, its access policy and, by default, two IAM roles so SNS can log successful and failed deliveries to CloudWatch Logs. Those logs are what tells you whether a message that never arrived was actually delivered.

```hcl
module "orders_topic" {
  source = "../../modules/sns-topic"

  name  = "orders"
  owner = "shop"
  env   = "prod"

  kms_master_key_id = "alias/aws/sns"

  # let another account subscribe its queues
  topic_policy_statements = {
    CrossAccountSubscribe = {
      actions    = ["sns:Subscribe"]
      principals = [{ type = "AWS", identifiers = ["arn:aws:iam::222222222222:root"] }]
    }
  }
}
```

Notes:

- The policy keeps the statement AWS adds by default (any principal in the account). Turn it off with `enable_default_topic_policy = false` if you want only your own statements.
- There's a 10 second wait after creating the IAM roles. Without it, the topic sometimes fails to create because SNS can't assume the role yet.
- FIFO topics get the `.fifo` suffix automatically.

All inputs are in [variables.tf](variables.tf).
