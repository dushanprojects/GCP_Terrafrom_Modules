variable "secret_id" {
  type        = string
  description = "The name of the secret"
}

variable "initial_version_enabled" {
  type        = bool
  default     = false
  description = "Whether an initial secret version is created from secret_data. Leave disabled when the value is added outside of Terraform"
}

variable "secret_data" {
  type        = string
  default     = null
  sensitive   = true
  description = "(Optional) The initial value of the secret. Only used when initial_version_enabled is true"
}

variable "replica_locations" {
  type        = list(string)
  default     = []
  description = "(Optional) List of regions the secret is replicated to. Leave empty to let Google manage the replication"
}

variable "encryption_kms_key_id" {
  type        = string
  default     = null
  description = "(Optional) The KMS key id used for the CMEK encryption of the secret. Applies to automatic replication only"
}

variable "rotation_period" {
  type        = string
  default     = null
  description = "(Optional) The interval the rotation notification is sent on, for example 7776000s for 90 days. Requires at least one entry in notification_topics"

  validation {
    condition     = var.rotation_period == null || length(var.notification_topics) > 0
    error_message = "notification_topics must contain at least one Pub/Sub topic when rotation_period is set, because Google sends the rotation notification to a topic."
  }
}

variable "next_rotation_time" {
  type        = string
  default     = null
  description = "(Optional) The timestamp of the next rotation notification in RFC 3339 format"
}

variable "notification_topics" {
  type        = list(string)
  default     = []
  description = "(Optional) List of Pub/Sub topic names that receive the rotation and version events of the secret"
}

variable "accessors" {
  type        = list(string)
  default     = []
  description = "(Optional) List of members allowed to read the secret value"
}

variable "additional_iam_bindings" {
  type = list(object({
    role   = string
    member = string
  }))
  default     = []
  description = "(Optional) Additional IAM bindings to apply to the secret"
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}
