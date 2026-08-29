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

variable "public_ip_cidr_range" {
  type        = string
  default     = "10.30.0.0/24"
  description = "The CIDR range of the VPC public networks"
}

variable "private_ip_cidr_range" {
  type        = string
  default     = "10.30.1.0/24"
  description = "The CIDR range of the VPC private networks"
}

variable "private_services_ip_range" {
  type        = string
  default     = "10.40.0.0"
  description = "The start of the IP range reserved for Google managed services such as Memorystore"
}

variable "private_services_prefix_length" {
  type        = number
  default     = 16
  description = "The prefix length of the IP range reserved for Google managed services"
}

variable "common_labels" {
  type        = map(any)
  description = "A map of key-value pairs to tag resources consistently"
  default = {
    team      = "sre"
    terrafrom = "true"
  }
}
