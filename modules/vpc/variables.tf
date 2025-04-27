variable "name" {
  type        = string
  description = "The name of the VPC"
}

variable "region" {
  type        = string
  description = "The GCP region where the VPC is created"
}

variable "common_labels" {
  type        = map(any)
  description = "A map of key-value pairs to tag resources consistently"
}

variable "public_ip_cidr_range" {
  type        = string
  description = "The CIDR range of the VPC public networks"
}

variable "private_ip_cidr_range" {
  type        = string
  description = "The CIDR range of the VPC private networks"
}

variable "pod_ip_cidr_range" {
  type        = string
  default     = ""
  description = "Cluster's subnetwork range to use for pods"
}

variable "services_ip_cidr_range" {
  type        = string
  default     = ""
  description = "Cluster's subnetwork range to use for service"
}

variable "master_ipv4_cidr_range" {
  type        = string
  default     = ""
  description = "(Optional) - The IP range in CIDR notation to use for the hosted master network"
}

variable "piblic_resource_tags" {
  type        = list(string)
  description = "Target public resources Tags to be allowed in Firewall rules"
  default     = ["public-subnet-resources"]
}

variable "private_instance_tags" {
  type        = list(string)
  description = "Target Private VM instance Tags to be allowed in Firewall rules"
  default     = ["private-instances", "nodepools"]
}
