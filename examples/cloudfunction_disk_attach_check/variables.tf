variable "project_id" {
  description = "Google Project ID"
  default     = "development-450619"
  sensitive   = true
}

variable "environment" {
  type        = string
  default     = "development"
  description = "The environment where the cluster is deployed (e.g., dev, prod)"
}

variable "region" {
  type        = string
  default     = "us-east1"
  description = "The GCP region where the VPC is created"
}

variable "common_labels" {
  type = map(any)
  default = {
    team      = "sre"
    terrafrom = "true"
    app_id    = "infra"
  }
}
