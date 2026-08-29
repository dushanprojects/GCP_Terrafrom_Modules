variable "name" {
  type        = string
  description = "The name of the Cloud Armor security policy"
}

variable "description" {
  type        = string
  default     = null
  description = "(Optional) A short description of what the security policy protects"
}

variable "type" {
  type        = string
  default     = "CLOUD_ARMOR"
  description = "The type of the security policy (CLOUD_ARMOR|CLOUD_ARMOR_EDGE|CLOUD_ARMOR_INTERNAL_SERVICE)"
}

variable "default_rule_action" {
  type        = string
  default     = "allow"
  description = "The action applied when no other rule matches (allow|deny(403)|deny(404)|deny(502))"
}

variable "adaptive_protection_enabled" {
  type        = bool
  default     = false
  description = "Whether Adaptive Protection watches for layer 7 attacks"
}

variable "adaptive_protection_rule_visibility" {
  type        = string
  default     = "STANDARD"
  description = "How much detail Adaptive Protection reports (STANDARD|PREMIUM)"
}

variable "denied_ip_ranges" {
  type        = list(string)
  default     = []
  description = "(Optional) List of IP ranges in CIDR notation that are blocked"
}

variable "allowed_ip_ranges" {
  type        = list(string)
  default     = []
  description = "(Optional) List of IP ranges in CIDR notation that are allowed. Used together with a deny default rule"
}

variable "waf_rules" {
  type = list(object({
    expression = string
    action     = optional(string, "deny(403)")
    preview    = optional(bool, false)
  }))
  default     = []
  description = "(Optional) List of preconfigured WAF rules, for example evaluatePreconfiguredExpr('sqli-v33-stable')"
}

variable "rate_limit_threshold_count" {
  type        = number
  default     = null
  description = "(Optional) The number of requests a single client is allowed to send in the interval"
}

variable "rate_limit_interval_sec" {
  type        = number
  default     = 60
  description = "The length of the rate limit interval in seconds"
}

variable "rate_limit_enforce_on_key" {
  type        = string
  default     = "IP"
  description = "What the rate limit is counted against (IP|ALL|HTTP_HEADER|XFF_IP|HTTP_COOKIE)"
}

variable "rate_limit_ban_duration_sec" {
  type        = number
  default     = 300
  description = "How long a client is banned for in seconds after it passes the rate limit"
}
