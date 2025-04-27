variable "region" {
  type        = string
  description = "Default Region"
}

variable "name" {
  type        = string
  description = "A user-defined name of the function. Function names must be unique globally."
}

variable "description" {
  type        = string
  description = "(Optional) Description of the function."
  default     = ""
}

variable "runtime" {
  type        = string
  description = "The runtime in which the function is going to run"
  default     = "nodejs22" # "nodejs22", "python311", "dotnet3", "go123", "java21", "ruby30", "php83",
}

variable "source_archive_file_name" {
  type        = string
  description = "The source archive object (file) the function is going use"
}

variable "available_memory_mb" {
  type        = number
  description = "Memory (in MB) allocation for the function. Default value is 256. Possible values include 128, 256, 512, 1024, etc."
  default     = 256
}

variable "timeout" {
  type        = number
  description = "Timeout (in seconds) for the function. Default value is 60 seconds. Cannot be more than 540 seconds."
  default     = 120
}

variable "kms_key_name" {
  type        = string
  description = "(Optional) Resource name of a KMS crypto key (managed by the user) used to encrypt/decrypt function resources"
  default     = ""
}

variable "entry_point" {
  type        = string
  description = "Name of the function that will be executed when the Google Cloud Function is triggered"
  default     = "helloGET"
}

variable "event_trigger_enabled" {
  type        = bool
  description = "A source that fires events in response to a condition in another service. Cannot be used with trigger_http"
  default     = false
}

variable "cron_schedule" {
  description = "Cron expression used in the function - Optional"
  type        = string
  default     = "0 */6 * * *"
}

variable "time_zone" {
  description = "Time zone for the cron schedule - Optional"
  type        = string
  default     = "UTC"
}

variable "environment_variables" {
  type        = map(any)
  default     = {}
  description = "A set of key/value environment variable pairs to assign to the function - Optional"
}

variable "common_labels" {
  type        = map(any)
  default     = {}
  description = "A map of key-value pairs to tag resources consistently - Optional"
}
