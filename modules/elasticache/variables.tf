variable "name" {
  description = "Cache name. Used for the replication group (truncated to 40 chars), subnet group, SG and parameter group."
  type        = string
}

variable "description" {
  description = "Replication group description."
  type        = string
  default     = null
}

variable "engine" {
  description = "redis or valkey."
  type        = string
  default     = "valkey"

  validation {
    condition     = contains(["redis", "valkey"], var.engine)
    error_message = "engine must be redis or valkey."
  }
}

variable "size" {
  description = "Sizing preset: xs, s, m, l, xl, xxl. See presets.tf."
  type        = string
  default     = "xs"

  validation {
    condition     = contains(["xs", "s", "m", "l", "xl", "xxl"], var.size)
    error_message = "Unknown size, see presets.tf."
  }
}

variable "cluster_mode" {
  description = "Enable cluster mode (sharding). Always HA."
  type        = bool
  default     = false
}

variable "num_shards" {
  description = "Number of shards when cluster_mode is enabled."
  type        = number
  default     = 1
}

variable "port" {
  description = "Port."
  type        = number
  default     = 6379
}

variable "vpc_id" {
  description = "VPC where the security group is created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the subnet group (private, in different AZs)."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect (e.g. the app's or the EKS nodes')."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDRs allowed to connect."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Extra security groups attached to the cache."
  type        = list(string)
  default     = []
}

variable "user_group_id" {
  description = "ElastiCache user group for RBAC authentication."
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key for encryption at rest. Defaults to the AWS managed key."
  type        = string
  default     = null
}

variable "snapshot_retention_limit" {
  description = "Days to keep automatic snapshots. Only for sizes with backups (xl, xxl)."
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "Daily snapshot window (UTC). Must not overlap the maintenance window."
  type        = string
  default     = "03:00-04:00"
}

variable "parameters" {
  description = "Extra parameters, or overrides of the defaults (maxmemory-policy, tcp-keepalive)."
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "apply_immediately" {
  description = "Apply changes right away instead of in the maintenance window."
  type        = bool
  default     = false
}

variable "engine_version_override" {
  description = "Use this engine version instead of the preset's."
  type        = string
  default     = null
}

variable "node_type_override" {
  description = "Use this node type instead of the preset's."
  type        = string
  default     = null
}

variable "replicas_override" {
  description = "Use this number of replicas instead of the preset's."
  type        = number
  default     = null
}

variable "tags" {
  description = "Tags for every resource."
  type        = map(string)
  default     = {}
}
