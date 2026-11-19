# terraform-custom-modules

Reusable, tested Terraform modules for AWS messaging and caching: SNS, SQS and ElastiCache.

The idea behind them is that a team can create a topic, a queue or a cache without knowing every setting of the service, and still end up with consistent names, encryption and sizing across environments and accounts. That makes them a good fit as the building blocks of a self-service platform, where developers request infrastructure themselves instead of opening a ticket.

| Module | What it creates |
|--------|-----------------|
| [sns-topic](modules/sns-topic) | SNS topic, access policy and IAM roles for delivery status logs |
| [sns-subscription](modules/sns-subscription) | Subscription with filter policy, raw delivery and DLQ |
| [sqs](modules/sqs) | Queue, optional DLQ (locked to its source queue), policy and Lambda triggers |
| [elasticache](modules/elasticache) | Redis/Valkey replication group sized from presets (`xs` ... `xxl`) |
| [elasticache-serverless](modules/elasticache-serverless) | Valkey/Redis serverless cache with usage limits |

## Self-service platforms

The modules are designed so they can sit behind an internal developer platform (Backstage software templates, Port, HCP Terraform no-code modules, AWS Service Catalog or a custom portal) and be filled in from a form:

- **Few inputs.** A queue needs `name`, `owner` and `env`; a cache needs `name` and `size`. Everything else has a safe default, so the form stays short.
- **Validation before the plan.** Invalid environments, unknown sizes or a name that already includes the environment fail with a clear message, so the developer sees the error in the form instead of in a failed pipeline.
- **Guardrails built in.** Encryption, naming and DLQ settings come from the module, not from whoever fills the form, so every team gets the same baseline.
- **Sizes instead of instance types.** Developers choose `s` or `xl`. The platform team decides what that means in `presets.tf` and can change it for everyone in one place.
- **Useful outputs.** ARNs, URLs and endpoints come back as outputs, ready to be written to the service's config or a secret store.

A form for a cache could be as small as this:

```yaml
cache:
  name: checkout-sessions   # text
  engine: valkey            # valkey | redis
  size: m                   # xs | s | m | l | xl | xxl
  allowed_security_group: sg-0123456789abcdef0
```

## Naming

SNS and SQS build the name from four parts so you can tell who owns a resource and where it lives just by reading it:

```
<owner>-<region>-<name>-<env>      shop-use1-orders-dev
                                   billing-sae1-payments-dlq-prod.fifo
```

The region is shortened automatically (`us-east-1` → `use1`) and `development`/`staging`/`production` become `dev`/`stg`/`prod`. If someone passes `orders-prod` as the name, validation fails so the environment doesn't end up twice in the name.

## ElastiCache presets

Most teams don't want to choose node types, replicas and snapshot windows. They pick a size and the module resolves the rest:

| Size | Node | Replicas | Multi-AZ | Backups | Meant for |
|------|------|:--------:|:--------:|:-------:|-----------|
| xs | cache.t4g.micro | 0 | | | dev |
| s | cache.t4g.small | 0 | | | dev |
| m | cache.t4g.small | 1 | ✓ | | staging |
| l | cache.t4g.medium | 2 | ✓ | | staging |
| xl | cache.r7g.large | 2 | ✓ | ✓ | production |
| xxl | cache.r7g.xlarge | 3 | ✓ | ✓ | production |

Anything can still be overridden (`node_type_override`, `replicas_override`, `parameters`...). The `settings` output shows what a size ended up being.

## Example

[`examples/sns-sqs-fanout`](examples/sns-sqs-fanout) is the typical setup these modules are meant for: one topic per domain and one queue per consumer, each subscription filtering only the events it needs.

```hcl
module "orders_topic" {
  source = "github.com/naktakalah/terraform-custom-modules//modules/sns-topic"

  name  = "orders"
  owner = "shop"
  env   = "dev"
}

module "billing_queue" {
  source = "github.com/naktakalah/terraform-custom-modules//modules/sqs"

  name       = "billing"
  owner      = "shop"
  env        = "dev"
  create_dlq = true
}

module "billing_subscription" {
  source = "github.com/naktakalah/terraform-custom-modules//modules/sns-subscription"

  topic_arn            = module.orders_topic.topic_arn
  protocol             = "sqs"
  endpoint             = module.billing_queue.queue_arn
  raw_message_delivery = true
  filter_policy        = { event_type = ["order_created"] }
}
```

There are also examples for [elasticache](examples/elasticache) and [elasticache-serverless](examples/elasticache-serverless).

## Tests

`sns-topic`, `sqs` and `elasticache` have tests written with `terraform test` and mocked providers, so they run without an AWS account:

```bash
cd modules/elasticache
terraform init
terraform test
```

They check the naming, the FIFO suffixes, the DLQ, encryption defaults and how the ElastiCache presets resolve.

[`examples/github-actions/modules-ci.yml`](examples/github-actions/modules-ci.yml) is a CI pipeline for this repo (fmt, validate, tflint and tests for every module). It's there as an example and doesn't run here.

## Design decisions

- **No hidden dependencies.** Tags are a plain variable and the ElastiCache sizes live in `presets.tf`, with the engine version kept apart from the size so the same block isn't repeated for every engine.
- **Encrypted by default.** SQS uses SSE unless you pass a KMS key, ElastiCache always has encryption in transit and at rest, and SNS takes a KMS key in one variable.
- **Safe defaults over cheap ones.** ElastiCache changes wait for the maintenance window (`apply_immediately = false`), DLQs keep messages for 14 days and only accept messages from their own queue.
- **Opt-in extras.** Queue policies, DLQs and Lambda triggers are only created when you ask for them, so a minimal call creates a minimal resource.
- **Any region.** The short region code in the names is derived from the provider region, nothing is hardcoded.
