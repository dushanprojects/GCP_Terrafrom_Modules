variable "key_name" {
  description = "Name of the crypto key"
  type        = string
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}

variable "kms_ring_id" {
  type        = string
  description = "The full ID of the KMS key ring"
}

variable "rotation_period" {
  type        = string
  default     = "2592000s" # 30 days
  description = "Interval to auto-rotate and set a new primary CryptoKeyVersion"
}

variable "additional_iam_bindings" {
  description = "Optional IAM bindings to apply to KMS key"
  type = list(object({
    role   = string
    member = string
  }))
  default = []
}
