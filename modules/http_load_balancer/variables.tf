variable "name" {
  type        = string
  description = "The name used as the prefix of every load balancer resource"
}

variable "region" {
  type        = string
  description = "The region the Cloud Run service runs in"
}

variable "cloud_run_service_name" {
  type        = string
  description = "The name of the Cloud Run service the load balancer sends traffic to"
}

variable "domains" {
  type        = list(string)
  default     = []
  description = "List of domains the Google managed certificate is issued for. Required when ssl_certificate_id is not set"
}

variable "description" {
  type        = string
  default     = null
  description = "(Optional) A short description of what the load balancer serves"
}

variable "ssl_certificate_id" {
  type        = string
  default     = null
  description = "(Optional) The id of an existing SSL certificate. Leave unset to create a Google managed certificate"
}

variable "ssl_policy_id" {
  type        = string
  default     = null
  description = "(Optional) The id of the SSL policy that sets the minimum TLS version and the allowed ciphers"
}

variable "security_policy_id" {
  type        = string
  default     = null
  description = "(Optional) The id of the Cloud Armor security policy attached to the backend service"
}

variable "http_redirect_enabled" {
  type        = bool
  default     = true
  description = "Whether plain HTTP traffic is redirected to HTTPS"
}

variable "backend_timeout_sec" {
  type        = number
  default     = 30
  description = "The time in seconds the backend is allowed to take before the request fails"
}

variable "request_logging_enabled" {
  type        = bool
  default     = true
  description = "Whether the load balancer writes request logs to Cloud Logging"
}

variable "request_logging_sample_rate" {
  type        = number
  default     = 1
  description = "The share of requests written to the logs, from 0 to 1"
}

variable "cdn_enabled" {
  type        = bool
  default     = false
  description = "Whether Cloud CDN caches the responses of the backend"
}

variable "cdn_cache_mode" {
  type        = string
  default     = "CACHE_ALL_STATIC"
  description = "What Cloud CDN caches (CACHE_ALL_STATIC|USE_ORIGIN_HEADERS|FORCE_CACHE_ALL)"
}

variable "cdn_default_ttl" {
  type        = number
  default     = 3600
  description = "The default time in seconds a response is cached for"
}

variable "cdn_max_ttl" {
  type        = number
  default     = 86400
  description = "The longest time in seconds a response is cached for"
}
