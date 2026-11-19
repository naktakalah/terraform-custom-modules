variable "name" {
  description = "Unique part of the queue name. The final name is <owner>-<region>-<name>-<env>."
  type        = string

  validation {
    condition     = !can(regex("\\b(use1|sae1|prod|stg|dev|qa|lab|dlq)\\b", var.name))
    error_message = "Pass only the unique part of the name, without region, environment or dlq."
  }
}

variable "owner" {
  description = "Team or domain that owns the queue. First part of the name."
  type        = string
}

variable "env" {
  description = "Environment. Long names (development, staging, production) are shortened."
  type        = string

  validation {
    condition     = contains(["lab", "dev", "qa", "stg", "prod", "development", "staging", "production"], var.env)
    error_message = "Valid values: lab, dev, qa, stg, prod, development, staging, production."
  }
}

variable "tags" {
  description = "Tags for every resource."
  type        = map(string)
  default     = {}
}

variable "delay_seconds" {
  description = "Delay before new messages become visible (0-900)."
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Max message size in bytes (1024-262144)."
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "How long messages are kept (60-1209600). Default 4 days."
  type        = number
  default     = 345600
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait (0-20). 20 is usually what you want, it cuts empty receives."
  type        = number
  default     = 20
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout (0-43200). With Lambda it should be at least 6x the function timeout."
  type        = number
  default     = 30
}

variable "policy" {
  description = "Queue access policy as an HCL object. null to not manage it."
  type        = any
  default     = null
}

variable "fifo_queue" {
  description = "Create a FIFO queue."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Content-based deduplication (FIFO only)."
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = "messageGroup or queue (FIFO only). messageGroup + perMessageGroupId = high throughput FIFO."
  type        = string
  default     = null
}

variable "fifo_throughput_limit" {
  description = "perQueue or perMessageGroupId (FIFO only)."
  type        = string
  default     = null
}

variable "sqs_managed_sse_enabled" {
  description = "Encrypt with SQS owned keys. Ignored when kms_master_key_id is set."
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "KMS key for encryption. Senders (e.g. SNS) need kms:GenerateDataKey and kms:Decrypt on it."
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "How long SQS reuses a data key before calling KMS again (60-86400)."
  type        = number
  default     = 300
}

variable "create_dlq" {
  description = "Create a dead-letter queue."
  type        = bool
  default     = false
}

variable "dlq_max_receive_count" {
  description = "Receives before a message is moved to the DLQ."
  type        = number
  default     = 5
}

variable "dlq_message_retention_seconds" {
  description = "Retention for the DLQ. Default is the max, 14 days."
  type        = number
  default     = 1209600
}

variable "event_source_mappings" {
  description = <<-EOT
    Lambda functions that consume the queue, keyed by any name. Each one accepts:
    function_name (required), enabled, batch_size, maximum_batching_window_in_seconds,
    maximum_concurrency, report_batch_item_failures and filter_patterns (list of objects).
  EOT
  type        = any
  default     = {}
}
