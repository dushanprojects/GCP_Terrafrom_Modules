variable "repository_id" {
  type        = string
  description = "The name of the Artifact Registry repository"
}

variable "location" {
  type        = string
  description = "The location where the repository is created"
}

variable "format" {
  type        = string
  default     = "DOCKER"
  description = "The format of packages stored in the repository, for example DOCKER, MAVEN, NPM or PYTHON"
}

variable "mode" {
  type        = string
  default     = "STANDARD_REPOSITORY"
  description = "The mode of the repository (STANDARD_REPOSITORY|REMOTE_REPOSITORY|VIRTUAL_REPOSITORY)"
}

variable "description" {
  type        = string
  default     = null
  description = "(Optional) A short description of what the repository holds"
}

variable "encryption_kms_key_id" {
  type        = string
  default     = null
  description = "(Optional) The KMS key id used for the CMEK encryption of the repository"
}

variable "immutable_tags_enabled" {
  type        = bool
  default     = false
  description = "Whether image tags are prevented from being overwritten. Applies to DOCKER repositories only"
}

variable "cleanup_policy_dry_run" {
  type        = bool
  default     = true
  description = "Whether the cleanup policies only report what they would delete instead of deleting it"
}

variable "delete_older_than" {
  type        = string
  default     = null
  description = "(Optional) Deletes images older than this duration in seconds, for example 2592000s for 30 days"
}

variable "delete_untagged_only" {
  type        = bool
  default     = true
  description = "Whether the delete policy only applies to untagged images"
}

variable "keep_most_recent_count" {
  type        = number
  default     = null
  description = "(Optional) The number of most recent images kept regardless of the delete policy"
}

variable "additional_iam_bindings" {
  type = list(object({
    role   = string
    member = string
  }))
  default     = []
  description = "(Optional) Additional IAM bindings to apply to the repository"
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}
