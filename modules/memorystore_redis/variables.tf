variable "name" {
  type        = string
  description = "The name of the Redis instance"
}

variable "region" {
  type        = string
  description = "The region the instance will sit in"
}

variable "display_name" {
  type        = string
  default     = null
  description = "(Optional) The display name of the Redis instance"
}

variable "tier" {
  type        = string
  default     = "STANDARD_HA"
  description = "The service tier of the instance (BASIC for a single node, STANDARD_HA for a replicated instance)"
}

variable "memory_size_gb" {
  type        = number
  default     = 1
  description = "The memory size of the instance in GB"
}

variable "redis_version" {
  type        = string
  default     = "REDIS_7_0"
  description = "The version of Redis the instance runs"
}

variable "location_id" {
  type        = string
  default     = null
  description = "(Optional) The zone the primary node sits in. Leave unset to let Google choose the zone"
}

variable "alternative_location_id" {
  type        = string
  default     = null
  description = "(Optional) The zone the replica node sits in. Applies to the STANDARD_HA tier only"
}

variable "authorized_network" {
  type        = string
  default     = null
  description = "(Optional) The VPC the instance is reached from. Defaults to the default network of the project"
}

variable "connect_mode" {
  type        = string
  default     = "PRIVATE_SERVICE_ACCESS"
  description = "How the instance is reached from the VPC (DIRECT_PEERING|PRIVATE_SERVICE_ACCESS)"
}

variable "reserved_ip_range" {
  type        = string
  default     = null
  description = "(Optional) The name of the allocated IP range the instance takes its address from"
}

variable "auth_enabled" {
  type        = bool
  default     = true
  description = "Whether clients have to send an auth string before they can use the instance"
}

variable "transit_encryption_mode" {
  type        = string
  default     = "SERVER_AUTHENTICATION"
  description = "Whether the traffic to the instance is encrypted (SERVER_AUTHENTICATION|DISABLED)"
}

variable "maintenance_window" {
  type = object({
    day  = string
    hour = number
  })
  default     = null
  description = "(Optional) Maintenance window, day of week such as SUNDAY and hour of day in UTC from 0 to 23"
}

variable "persistence_enabled" {
  type        = bool
  default     = true
  description = "Whether the instance writes RDB snapshots so the data survives a restart"
}

variable "rdb_snapshot_period" {
  type        = string
  default     = "TWENTY_FOUR_HOURS"
  description = "How often an RDB snapshot is taken (ONE_HOUR|SIX_HOURS|TWELVE_HOURS|TWENTY_FOUR_HOURS)"
}

variable "redis_configs" {
  type        = map(string)
  default     = {}
  description = "(Optional) A map of Redis configuration settings, for example maxmemory-policy"
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}
