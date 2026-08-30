variable "name" {
  type        = string
  description = "The name of the VPC"
}

variable "region" {
  type        = string
  description = "The GCP region where the VPC is created"
}

# Kept for the module interface, google_compute_network and google_compute_subnetwork do not support labels
# tflint-ignore: terraform_unused_declarations
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

# Kept for the module interface, the GKE cluster module takes this range directly
# tflint-ignore: terraform_unused_declarations
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

variable "public_allowed_tcp_ports" {
  type        = list(string)
  default     = ["80", "443"]
  description = "The TCP ports the public subnet resources accept traffic on from the internet"
}

variable "backend_allowed_tcp_ports" {
  type        = list(string)
  default     = ["80", "443", "30000-32767", "22"]
  description = "The TCP ports the private subnet resources accept traffic on from the public subnet"
}

variable "flow_logs_enabled" {
  type        = bool
  default     = false
  description = "Whether VPC flow logs are collected for the private subnet. The logs are charged per GB"
}

variable "flow_logs_aggregation_interval" {
  type        = string
  default     = "INTERVAL_5_SEC"
  description = "How often the flow logs are aggregated"
}

variable "flow_logs_sampling_rate" {
  type        = number
  default     = 0.5
  description = "The share of the traffic written to the flow logs, from 0 to 1"
}
