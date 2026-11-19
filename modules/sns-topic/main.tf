resource "aws_sns_topic" "this" {
  name         = local.name
  display_name = local.naming_prefix

  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null
  signature_version           = var.fifo_topic ? null : var.signature_version
  kms_master_key_id           = var.kms_master_key_id
  delivery_policy             = var.delivery_policy != null ? jsonencode(var.delivery_policy) : null

  application_success_feedback_role_arn    = local.success_role_arn
  application_success_feedback_sample_rate = local.success_sample_rate
  application_failure_feedback_role_arn    = local.failure_role_arn

  http_success_feedback_role_arn    = local.success_role_arn
  http_success_feedback_sample_rate = local.success_sample_rate
  http_failure_feedback_role_arn    = local.failure_role_arn

  lambda_success_feedback_role_arn    = local.success_role_arn
  lambda_success_feedback_sample_rate = local.success_sample_rate
  lambda_failure_feedback_role_arn    = local.failure_role_arn

  sqs_success_feedback_role_arn    = local.success_role_arn
  sqs_success_feedback_sample_rate = local.success_sample_rate
  sqs_failure_feedback_role_arn    = local.failure_role_arn

  tags = var.tags

  depends_on = [time_sleep.wait_iam_propagation]
}

data "aws_iam_policy_document" "this" {
  count = var.create_topic_policy ? 1 : 0

  # the statement AWS adds to every new topic
  dynamic "statement" {
    for_each = var.enable_default_topic_policy ? [true] : []

    content {
      sid = "__default_statement_ID"
      actions = [
        "sns:GetTopicAttributes",
        "sns:SetTopicAttributes",
        "sns:AddPermission",
        "sns:RemovePermission",
        "sns:DeleteTopic",
        "sns:Subscribe",
        "sns:ListSubscriptionsByTopic",
        "sns:Receive",
        "sns:Publish",
      ]
      resources = [aws_sns_topic.this.arn]

      principals {
        type        = "AWS"
        identifiers = ["*"]
      }

      condition {
        test     = "StringEquals"
        variable = "AWS:SourceOwner"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }

  dynamic "statement" {
    for_each = var.topic_policy_statements

    content {
      sid           = try(statement.value.sid, statement.key)
      effect        = try(statement.value.effect, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      resources     = try(statement.value.resources, [aws_sns_topic.this.arn])
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_sns_topic_policy" "this" {
  count = var.create_topic_policy ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this[0].json
}
