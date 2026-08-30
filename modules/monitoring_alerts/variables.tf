variable "project_id" {
  type        = string
  description = "Google Project ID the alerts are created in"
}

variable "notification_channels" {
  type = list(object({
    display_name = string
    type         = string
    labels       = map(string)
  }))
  default     = []
  description = "(Optional) List of channels the alerts are sent to, for example an email address or a Slack channel"
}

variable "uptime_checks" {
  type = list(object({
    display_name      = string
    host              = string
    path              = optional(string, "/")
    use_ssl           = optional(bool, true)
    period            = optional(string, "60s")
    timeout           = optional(string, "10s")
    failing_locations = optional(number, 2)
  }))
  default     = []
  description = "(Optional) List of endpoints checked from several locations around the world"
}

variable "metric_alerts" {
  type = list(object({
    display_name         = string
    filter               = string
    threshold_value      = number
    comparison           = optional(string, "COMPARISON_GT")
    duration             = optional(string, "300s")
    alignment_period     = optional(string, "300s")
    per_series_aligner   = optional(string, "ALIGN_RATE")
    cross_series_reducer = optional(string, "REDUCE_SUM")
    group_by_fields      = optional(list(string), [])
    documentation        = optional(string)
    enabled              = optional(bool, true)
  }))
  default     = []
  description = "(Optional) List of alerts raised on a metric, for example an error rate or a request latency"
}

variable "auto_close_duration" {
  type        = string
  default     = "86400s"
  description = "How long an alert stays open for after the data stops arriving"
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently"
}
