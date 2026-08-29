variable "name" {
  type        = string
  description = "The name of the VPC"
}

# Kept for the module interface, google_kms_key_ring does not support labels
# tflint-ignore: terraform_unused_declarations
variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}

# Kept for the module interface, rotation is set on the KMS key rather than on the key ring
# tflint-ignore: terraform_unused_declarations
variable "rotation_period" {
  type        = string
  default     = "2592000s" # 30 days
  description = "Every time this period passes, generate a new CryptoKeyVersion and set it as the primary"
}

variable "location" {
  type        = string
  default     = "global"
  description = "The location for the KeyRing."
}
