variable "project_id" {
  description = "Google Project ID"
  type        = string
  default     = "gcp-terraform-modules-test" # An example
  sensitive   = true
}

variable "region" {
  type        = string
  default     = "us-east1"
  description = "The GCP region where resources will be provisioned"
}

variable "domains" {
  type        = list(string)
  default     = ["app1.example.com"] # An example
  description = "The domains the load balancer serves and the managed certificate is issued for"
}

variable "common_labels" {
  type        = map(any)
  description = "A map of key-value pairs to tag resources consistently"
  default = {
    team      = "sre"
    terrafrom = "true"
  }
}
