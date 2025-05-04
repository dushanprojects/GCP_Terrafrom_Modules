variable "name" {
  type        = string
  description = "The name of the VPC"
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}

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
