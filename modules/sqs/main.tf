resource "aws_sqs_queue" "this" {
  name = local.name

  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = var.create_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.dlq_max_receive_count
  }) : null

  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  deduplication_scope         = var.fifo_queue ? var.deduplication_scope : null
  fifo_throughput_limit       = var.fifo_queue ? var.fifo_throughput_limit : null

  sqs_managed_sse_enabled           = local.sqs_managed_sse
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null

  tags = var.tags
}

resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name = local.dlq_name

  message_retention_seconds  = var.dlq_message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  sqs_managed_sse_enabled           = local.sqs_managed_sse
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null

  tags = var.tags
}

# separate resource, inline it would create a cycle with redrive_policy
resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  count = var.create_dlq ? 1 : 0

  queue_url = aws_sqs_queue.dlq[0].id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this.arn]
  })
}

resource "aws_sqs_queue_policy" "this" {
  count = var.policy != null ? 1 : 0

  queue_url = aws_sqs_queue.this.id
  policy    = jsonencode(var.policy)
}

resource "aws_lambda_event_source_mapping" "this" {
  for_each = var.event_source_mappings

  event_source_arn = aws_sqs_queue.this.arn
  function_name    = each.value.function_name
  enabled          = try(each.value.enabled, true)

  batch_size                         = try(each.value.batch_size, null)
  maximum_batching_window_in_seconds = try(each.value.maximum_batching_window_in_seconds, null)
  function_response_types            = try(each.value.report_batch_item_failures, false) ? ["ReportBatchItemFailures"] : null

  dynamic "scaling_config" {
    for_each = try(each.value.maximum_concurrency, null) != null ? [true] : []

    content {
      maximum_concurrency = each.value.maximum_concurrency
    }
  }

  dynamic "filter_criteria" {
    for_each = length(try(each.value.filter_patterns, [])) > 0 ? [true] : []

    content {
      dynamic "filter" {
        for_each = each.value.filter_patterns

        content {
          pattern = jsonencode(filter.value)
        }
      }
    }
  }
}
