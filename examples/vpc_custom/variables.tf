variable "project_id" {
  description = "Google Project ID"
  default     = "development-450619"
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
  }
}

variable "public_ip_cidr_range" {
  type        = string
  default     = "172.30.0.0/18"
  description = "The CIDR range of the VPC public networks"
}

variable "private_ip_cidr_range" {
  type        = string
  default     = "172.30.64.0/18"
  description = "The CIDR range of the VPC private networks"
}

variable "pod_ip_cidr_range" {
  type        = string
  default     = "172.30.192.0/18"
  description = "Cluster's subnetwork range to use for pods"
}

variable "services_ip_cidr_range" {
  type        = string
  default     = "172.30.128.0/18"
  description = "Cluster's subnetwork range to use for service"
}
