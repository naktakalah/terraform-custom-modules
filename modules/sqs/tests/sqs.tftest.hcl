mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      region = "sa-east-1"
    }
  }
}

variables {
  name  = "payments"
  owner = "billing"
  env   = "production"
}

run "naming_follows_convention" {
  command = plan

  assert {
    condition     = aws_sqs_queue.this.name == "billing-sae1-payments-prod"
    error_message = "unexpected queue name: ${aws_sqs_queue.this.name}"
  }
}

run "no_dlq_or_policy_by_default" {
  command = plan

  assert {
    condition     = length(aws_sqs_queue.dlq) == 0 && length(aws_sqs_queue_policy.this) == 0
    error_message = "dlq and policy should be opt-in"
  }
}

run "fifo_with_dlq" {
  command = plan

  variables {
    fifo_queue = true
    create_dlq = true
  }

  assert {
    condition     = aws_sqs_queue.this.name == "billing-sae1-payments-prod.fifo"
    error_message = "fifo queues need the .fifo suffix"
  }

  assert {
    condition     = aws_sqs_queue.dlq[0].name == "billing-sae1-payments-dlq-prod.fifo"
    error_message = "unexpected dlq name: ${aws_sqs_queue.dlq[0].name}"
  }

  assert {
    condition     = aws_sqs_queue.dlq[0].message_retention_seconds == 1209600
    error_message = "dlq should keep messages for 14 days"
  }
}

run "sqs_managed_sse_by_default" {
  command = plan

  assert {
    condition     = aws_sqs_queue.this.sqs_managed_sse_enabled == true
    error_message = "queues should be encrypted by default"
  }
}

run "kms_encryption" {
  command = plan

  variables {
    kms_master_key_id = "alias/aws/sqs"
  }

  assert {
    condition     = aws_sqs_queue.this.kms_master_key_id == "alias/aws/sqs" && aws_sqs_queue.this.kms_data_key_reuse_period_seconds == 300
    error_message = "kms settings not applied"
  }
}

run "rejects_env_in_name" {
  command = plan

  variables {
    name = "payments-prod"
  }

  expect_failures = [var.name]
}
