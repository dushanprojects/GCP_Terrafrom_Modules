variable "name" {
  type        = string
  description = "The name of the Cloud Run service"
}

variable "location" {
  type        = string
  description = "The region the service runs in"
}

variable "image" {
  type        = string
  description = "The container image the service runs, for example REGION-docker.pkg.dev/PROJECT/REPO/IMAGE:TAG"
}

variable "service_account_email" {
  type        = string
  default     = null
  description = "(Optional) The email address of the runtime service account. Defaults to the Compute Engine default service account"
}

variable "ingress" {
  type        = string
  default     = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  description = "Which traffic reaches the service (INGRESS_TRAFFIC_ALL|INGRESS_TRAFFIC_INTERNAL_ONLY|INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER)"
}

variable "container_port" {
  type        = number
  default     = 8080
  description = "The port the container listens on"
}

variable "cpu_limit" {
  type        = string
  default     = "1"
  description = "The number of CPUs available to each instance"
}

variable "memory_limit" {
  type        = string
  default     = "512Mi"
  description = "The memory available to each instance"
}

variable "cpu_always_allocated" {
  type        = bool
  default     = false
  description = "Whether the CPU stays allocated between requests. Required for background work outside a request"
}

variable "startup_cpu_boost_enabled" {
  type        = bool
  default     = true
  description = "Whether extra CPU is given to an instance while it starts up"
}

variable "min_instances" {
  type        = number
  default     = 0
  description = "The smallest number of instances kept running. Set to 1 or more to avoid cold starts"
}

variable "max_instances" {
  type        = number
  default     = 10
  description = "The largest number of instances the service scales out to"
}

variable "max_concurrent_requests" {
  type        = number
  default     = 80
  description = "The number of requests each instance handles at the same time"
}

variable "request_timeout" {
  type        = string
  default     = "300s"
  description = "The time a request is allowed to take before it is stopped"
}

variable "execution_environment" {
  type        = string
  default     = "EXECUTION_ENVIRONMENT_GEN2"
  description = "The runtime environment of the service (EXECUTION_ENVIRONMENT_GEN1|EXECUTION_ENVIRONMENT_GEN2)"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "(Optional) A map of plain environment variables passed to the container"
}

variable "secret_environment_variables" {
  type = list(object({
    name      = string
    secret_id = string
    version   = optional(string, "latest")
  }))
  default     = []
  description = "(Optional) List of environment variables read from Secret Manager"
}

variable "vpc_network" {
  type        = string
  default     = null
  description = "(Optional) The VPC outbound traffic of the service is sent through"
}

variable "vpc_subnetwork" {
  type        = string
  default     = null
  description = "(Optional) The subnet used for the outbound traffic of the service"
}

variable "vpc_egress" {
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
  description = "Which outbound traffic is sent through the VPC (ALL_TRAFFIC|PRIVATE_RANGES_ONLY)"
}

variable "startup_probe_path" {
  type        = string
  default     = null
  description = "(Optional) The HTTP path checked while the container starts up"
}

variable "startup_probe_initial_delay" {
  type        = number
  default     = 5
  description = "The time in seconds before the first startup check is made"
}

variable "startup_probe_period" {
  type        = number
  default     = 10
  description = "The time in seconds between startup checks"
}

variable "startup_probe_failure_threshold" {
  type        = number
  default     = 3
  description = "The number of failed startup checks before the instance is restarted"
}

variable "liveness_probe_path" {
  type        = string
  default     = null
  description = "(Optional) The HTTP path checked while the container is running"
}

variable "liveness_probe_period" {
  type        = number
  default     = 30
  description = "The time in seconds between liveness checks"
}

variable "invokers" {
  type        = list(string)
  default     = []
  description = "(Optional) List of members allowed to call the service. Use allUsers for a public service"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Whether Terraform will be prevented from destroying the service"
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}
