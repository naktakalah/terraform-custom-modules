variable "topic_arn" {
  description = "ARN of the topic to subscribe to."
  type        = string
}

variable "protocol" {
  description = "sqs, lambda, firehose, application, sms, email, email-json, http or https."
  type        = string

  validation {
    condition     = contains(["sqs", "lambda", "firehose", "application", "sms", "email", "email-json", "http", "https"], var.protocol)
    error_message = "Unsupported protocol."
  }
}

variable "endpoint" {
  description = "Where messages are delivered. Depends on the protocol (queue ARN, function ARN, URL...)."
  type        = string
}

variable "raw_message_delivery" {
  description = "Deliver the message as is, without the SNS JSON envelope (sqs, http/s and firehose)."
  type        = bool
  default     = false
}

variable "filter_policy" {
  description = "Filter policy as an HCL object. Only matching messages are delivered."
  type        = any
  default     = null
}

variable "filter_policy_scope" {
  description = "MessageAttributes or MessageBody."
  type        = string
  default     = "MessageAttributes"

  validation {
    condition     = contains(["MessageAttributes", "MessageBody"], var.filter_policy_scope)
    error_message = "Valid values: MessageAttributes, MessageBody."
  }
}

variable "dlq_arn" {
  description = "SQS queue for messages SNS fails to deliver to this endpoint."
  type        = string
  default     = null
}

variable "endpoint_auto_confirms" {
  description = "The endpoint confirms the subscription by itself (http/s only)."
  type        = bool
  default     = false
}

variable "confirmation_timeout_in_minutes" {
  description = "How long to wait for an http/s subscription to be confirmed."
  type        = number
  default     = 1
}
