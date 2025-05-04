variable "name" {
  type        = string
  description = "The name of the Storage Bucket"
}

variable "location" {
  type        = string
  description = "The location where you create bucket"
}

variable "public_access_prevention" {
  type        = string
  default     = "enforced"
  description = "Prevents public access to a bucket (inherited|enforced)"
}

variable "storage_class" {
  type        = string
  default     = "STANDARD"
  description = "The Storage Class of the new bucket"
}

variable "force_destroy_enabled" {
  type        = bool
  default     = false
  description = "When deleting a bucket, this boolean option will delete all contained objects"
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}

variable "log_bucket_name" {
  type        = string
  default     = ""
  description = "The bucket that will receive log objects"

}

variable "versioning_enabled" {
  type        = bool
  default     = false
  description = "Bucket versioning enabled|disabled"
}

variable "encryption_kms_key_id" {
  description = "(Optional) The bucket's encryption KMS key id"
  type        = string
  default     = ""
}

variable "lifecycle_rules" {
  description = "(Optional) List of lifecycle rules for the bucket"
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                        = optional(number)
      created_before             = optional(string)
      with_state                 = optional(string)
      matches_storage_class      = optional(list(string))
      matches_prefix             = optional(list(string))
      matches_suffix             = optional(list(string))
      num_newer_versions         = optional(number)
      custom_time_before         = optional(string)
      days_since_custom_time     = optional(number)
      days_since_noncurrent_time = optional(number)
      noncurrent_time_before     = optional(string)
    })
  }))
  default = []
}
