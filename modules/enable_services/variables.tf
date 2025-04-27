variable "apis" {
  type = list(string)
  default = [
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com"
  ]
}

variable "project_id" {
  type        = string
  description = "Get Google Project ID value from terrafrom.auto.tfvars"
  sensitive   = true
}
