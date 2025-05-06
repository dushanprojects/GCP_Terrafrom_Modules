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
  description = "The Google Project ID"
  sensitive   = true
}
