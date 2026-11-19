variable "name" {
  description = "Unique part of the topic name. The final name is <owner>-<region>-<name>-<env>."
  type        = string

  validation {
    # \b so it only fails when the word is on its own, e.g. "orders-prod" but not "product-events"
    condition     = !can(regex("\\b(use1|sae1|prod|stg|dev|qa|lab)\\b", var.name))
    error_message = "Pass only the unique part of the name, without region or environment."
  }
}

variable "owner" {
  description = "Team or domain that owns the topic. First part of the name."
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

variable "fifo_topic" {
  description = "Create a FIFO topic."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Content-based deduplication (FIFO only)."
  type        = bool
  default     = false
}

variable "signature_version" {
  description = "1 (SHA1) or 2 (SHA256) for the signature of the messages SNS sends."
  type        = number
  default     = 2
}

variable "kms_master_key_id" {
  description = "KMS key for server-side encryption. alias/aws/sns for the AWS managed key."
  type        = string
  default     = null
}

variable "delivery_policy" {
  description = "Delivery/retry policy for HTTP(S) endpoints, as an HCL object."
  type        = any
  default     = null
}

variable "create_topic_policy" {
  description = "Manage the topic access policy."
  type        = bool
  default     = true
}

variable "enable_default_topic_policy" {
  description = "Include the default statement (any principal in this account)."
  type        = bool
  default     = true
}

variable "topic_policy_statements" {
  description = <<-EOT
    Extra policy statements, keyed by sid. Each one accepts: effect, actions, not_actions,
    resources (defaults to the topic), not_resources, principals, not_principals and
    conditions (list of { test, variable, values }).
  EOT
  type        = any
  default     = {}
}

variable "create_success_role" {
  description = "Create the IAM role to log successful deliveries."
  type        = bool
  default     = true
}

variable "success_sample_rate" {
  description = "Percentage of successful deliveries to log."
  type        = number
  default     = 100
}

variable "success_policy" {
  description = "Custom policy for the success role. Defaults to CloudWatch Logs write access."
  type        = any
  default     = null
}

variable "create_failure_role" {
  description = "Create the IAM role to log failed deliveries."
  type        = bool
  default     = true
}

variable "failure_policy" {
  description = "Custom policy for the failure role. Defaults to CloudWatch Logs write access."
  type        = any
  default     = null
}
