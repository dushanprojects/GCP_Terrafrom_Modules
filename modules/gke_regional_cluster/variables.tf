variable "project_id" {
  type        = string
  description = "The ID of the GCP project where resources will be created."
}

variable "cluster_name" {
  type        = string
  default     = "example"
  description = "The name of the Kubernetes cluster."
}

variable "min_master_version" {
  type        = string
  description = "value"
}

variable "region" {
  type        = string
  description = "The GCP region where resources will be provisioned."
}

variable "private_subnet_id" {
  type        = string
  description = "The ID of the private subnet used for internal communication."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the custom VPC where the cluster will be deployed."
}

variable "master_ipv4_cidr" {
  type        = string
  default     = "172.16.0.0/28"
  description = "(Optional) - The IP range in CIDR notation to use for the hosted master network"
}

variable "custom_vpc_used" {
  type        = bool
  default     = false
  description = "Set to true if using a custom VPC; used for naming conventions of pods and services."
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}

variable "private_instance_tags" {
  type        = list(string)
  description = "Target Private VM instance Tags to be allowed in Firewall rules"
  default     = ["private-instances", "nodepools"]
}

variable "maintenance_recurring_window" {
  type = object({
    start_time = string
    end_time   = string
    recurrence = string
  })
  default = {
    start_time = "2025-02-14T00:00:00Z"
    end_time   = "2025-02-15T00:00:00Z"
    recurrence = "FREQ=WEEKLY;BYDAY=SU"
  }
  description = "(Optional) The maintenance policy to use for the cluster."
}

variable "ip_whitelisting" {
  description = "A list of authorized CIDR blocks for network access control."
  default     = []
  type = list(object({
    display_name = string
    cidr_block   = string
  }))
}

variable "release_channel" {
  type        = string
  default     = "REGULAR"
  description = "Release channel used for GKE cluster patching"
}

variable "gke_managed_components_nodepool" {
  type = object({
    min_node_count = optional(number)
    max_node_count = optional(number)
    machine_type   = optional(string)
    disk_size_gb   = optional(number)
    disk_type      = optional(string)
    node_taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
  })
  default     = null
  description = <<EOS
Configuration for the GKE managed components node pool:
- min_node_count (number)
- max_node_count (number)
- machine_type (string)
- disk_size_gb (number)
- disk_type (string)
- node_taints (list of maps with key, value, and effect)
EOS
}


variable "application_nodepools" {
  type        = list(any)
  default     = []
  description = <<EOS
  List of number, maps or string related to application nodepools
  - min_node_count (number)
  - max_node_count (number)
  - machine_type (string)
  - disk_size_gb (number)
  - disk_type (string)
  - node_taints (map)
  EOS
}
