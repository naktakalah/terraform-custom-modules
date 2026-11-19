variable "name" {
  description = "Cache name."
  type        = string
}

variable "description" {
  description = "Cache description."
  type        = string
  default     = null
}

variable "engine" {
  description = "valkey or redis. Valkey serverless is cheaper and starts at a lower minimum."
  type        = string
  default     = "valkey"

  validation {
    condition     = contains(["valkey", "redis"], var.engine)
    error_message = "engine must be valkey or redis."
  }
}

variable "major_engine_version" {
  description = "Major engine version. Defaults to 8 for valkey and 7 for redis."
  type        = string
  default     = null
}

variable "cache_usage_limits" {
  description = "Caps on storage (GB) and ECPUs per second, mostly to keep the bill under control."
  type = object({
    data_storage = optional(object({
      maximum = optional(number)
      minimum = optional(number)
      unit    = optional(string, "GB")
    }))
    ecpu_per_second = optional(object({
      maximum = optional(number)
      minimum = optional(number)
    }))
  })
  default = {}
}

variable "subnet_ids" {
  description = "Private subnets for the cache endpoints."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for the cache endpoints."
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key for encryption at rest. Defaults to the AWS managed key."
  type        = string
  default     = null
}

variable "user_group_id" {
  description = "ElastiCache user group for RBAC authentication."
  type        = string
  default     = null
}

variable "daily_snapshot_time" {
  description = "Daily snapshot time (UTC), e.g. 03:00."
  type        = string
  default     = null
}

variable "snapshot_retention_limit" {
  description = "Days to keep snapshots. 0 disables them."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags for every resource."
  type        = map(string)
  default     = {}
}
