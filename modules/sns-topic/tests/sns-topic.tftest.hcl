mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "111111111111"
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

mock_provider "time" {}

variables {
  name  = "orders"
  owner = "shop"
  env   = "development"
}

run "naming_follows_convention" {
  command = plan

  assert {
    condition     = aws_sns_topic.this.name == "shop-use1-orders-dev"
    error_message = "unexpected topic name: ${aws_sns_topic.this.name}"
  }

  assert {
    condition     = aws_sns_topic.this.signature_version == 2
    error_message = "standard topics should sign with SHA256"
  }
}

run "fifo_topic" {
  command = plan

  variables {
    fifo_topic = true
  }

  assert {
    condition     = aws_sns_topic.this.name == "shop-use1-orders-dev.fifo"
    error_message = "fifo topics need the .fifo suffix"
  }
}

run "no_feedback_roles" {
  command = plan

  variables {
    create_success_role = false
    create_failure_role = false
  }

  assert {
    condition     = length(aws_iam_role.success) == 0 && length(aws_iam_role.failure) == 0 && length(time_sleep.wait_iam_propagation) == 0
    error_message = "roles and the IAM wait should be skipped"
  }
}
