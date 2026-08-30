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

variable "alert_email_address" {
  type        = string
  default     = "sre@example.com" # An example
  description = "The email address the alerts are sent to"
}

variable "monitored_host" {
  type        = string
  default     = "app1.example.com" # An example
  description = "The public host name the uptime check requests"
}

variable "common_labels" {
  type        = map(any)
  description = "A map of key-value pairs to tag resources consistently"
  default = {
    team      = "sre"
    terrafrom = "true"
  }
}
