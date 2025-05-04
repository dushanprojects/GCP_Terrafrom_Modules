variable "project_id" {
  description = "Google Project ID"
  type        = string
  default     = "gcp-terraform-modules-test" # An example
  sensitive   = true
}

variable "region" {
  type        = string
  default     = "us-east1"
  description = "The GCP region where the VPC is created"
}

variable "common_labels" {
  type        = map(any)
  description = "A map of key-value pairs to tag resources consistently"
  default = {
    team      = "sre"
    terrafrom = "true"
  }
}
