variable "name" {
  type        = string
  description = "The name of the DB instance"
}

variable "region" {
  type        = string
  description = "The region the instance will sit in"
}

variable "database_version" {
  type        = string
  default     = "MYSQL_8_0"
  description = "The MySQL Server version to use"
}

variable "maintenance_version" {
  type        = string
  default     = null
  description = "(Optional) The current software version on the instance. Leave unset to let Google manage it"
}

variable "master_instance_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the existing instance that will act as the master in the replication setup"
}

variable "root_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "(Optional) Initial root password. Can be updated"
}

variable "encryption_key_name" {
  type        = string
  default     = null
  description = "(Optional) The full path to the encryption key used for the CMEK disk encryption"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Whether Terraform will be prevented from destroying the instance"
}

variable "api_deletion_protection_enabled" {
  type        = bool
  default     = true
  description = "Whether the instance is protected against deletion by the Cloud SQL API and Console"
}

variable "tier" {
  type        = string
  default     = "db-f1-micro"
  description = "The machine type to use (for example db-f1-micro, db-custom-2-7680)"
}

variable "edition" {
  type        = string
  default     = "ENTERPRISE"
  description = "The edition of the instance (ENTERPRISE|ENTERPRISE_PLUS)"
}

variable "availability_type" {
  type        = string
  default     = "ZONAL"
  description = "The availability type of the instance (ZONAL for single zone, REGIONAL for HA)"
}

variable "disk_type" {
  type        = string
  default     = "PD_SSD"
  description = "The type of data disk (PD_SSD|PD_HDD)"
}

variable "disk_size" {
  type        = number
  default     = 10
  description = "The size of data disk in GB"
}

variable "disk_autoresize_enabled" {
  type        = bool
  default     = true
  description = "Whether the data disk grows automatically as storage fills up"
}

variable "disk_autoresize_limit" {
  type        = number
  default     = 0
  description = "The maximum size the data disk can grow to in GB (0 means no limit)"
}

variable "public_ip_enabled" {
  type        = bool
  default     = false
  description = "Whether the instance is assigned a public IPv4 address"
}

variable "private_network" {
  type        = string
  default     = null
  description = "(Optional) The self link of the VPC the instance is served from over private IP. Requires a private services access connection on that VPC"
}

variable "allocated_ip_range" {
  type        = string
  default     = null
  description = "(Optional) The name of the allocated IP range used for the private IP address"
}

variable "private_path_for_google_cloud_services_enabled" {
  type        = bool
  default     = false
  description = "Whether Google Cloud services such as BigQuery can reach the instance over private IP"
}

variable "ssl_mode" {
  type        = string
  default     = "ENCRYPTED_ONLY"
  description = "Enforcement of SSL/TLS on connections (ALLOW_UNENCRYPTED_AND_ENCRYPTED|ENCRYPTED_ONLY|TRUSTED_CLIENT_CERTIFICATE_REQUIRED)"
}

variable "authorized_networks" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "(Optional) List of external networks allowed to connect over public IP"
}

variable "backup_enabled" {
  type        = bool
  default     = true
  description = "Whether automated backups are taken. Must be disabled on read replicas"
}

variable "binary_log_enabled" {
  type        = bool
  default     = true
  description = "Whether binary logging is enabled. Required for point in time recovery and read replicas"
}

variable "backup_start_time" {
  type        = string
  default     = "23:00"
  description = "HH:MM format time in UTC the backup window starts"
}

variable "backup_location" {
  type        = string
  default     = null
  description = "(Optional) The region the backups are stored in. Defaults to the multi-region closest to the instance"
}

variable "transaction_log_retention_days" {
  type        = number
  default     = 7
  description = "The number of days transaction logs are retained for point in time recovery"
}

variable "retained_backups" {
  type        = number
  default     = 7
  description = "The number of automated backups to retain"
}

variable "maintenance_window" {
  type = object({
    day          = number
    hour         = number
    update_track = optional(string, "stable")
  })
  default     = null
  description = "(Optional) Maintenance window - day of week (1 Monday to 7 Sunday), hour of day in UTC (0 to 23) and update track"
}

variable "database_flags" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "(Optional) List of MySQL server flags to set on the instance"
}

variable "query_insights_enabled" {
  type        = bool
  default     = false
  description = "Whether Query Insights is enabled on the instance"
}

variable "query_string_length" {
  type        = number
  default     = 1024
  description = "The maximum query length stored in bytes (256 to 4500)"
}

variable "record_application_tags" {
  type        = bool
  default     = false
  description = "Whether Query Insights collects application tags from the query"
}

variable "record_client_address" {
  type        = bool
  default     = false
  description = "Whether Query Insights collects the client address of the query"
}

variable "databases" {
  type = list(object({
    name      = string
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_general_ci")
  }))
  default     = []
  description = "(Optional) List of databases to create on the instance"
}

variable "users" {
  type = list(object({
    name     = string
    password = string
    host     = optional(string, "%")
  }))
  default     = []
  sensitive   = true
  description = "(Optional) List of users to create on the instance"
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}
