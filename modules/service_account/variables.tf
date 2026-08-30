variable "project_id" {
  type        = string
  description = "Google Project ID the service account is created in"
}

variable "account_id" {
  type        = string
  description = "The account id of the service account, used as the first part of the email address"
}

variable "display_name" {
  type        = string
  default     = null
  description = "(Optional) The display name of the service account"
}

variable "description" {
  type        = string
  default     = null
  description = "(Optional) A short description of what the service account is used for"
}

variable "project_roles" {
  type        = list(string)
  default     = []
  description = "(Optional) List of project level roles granted to the service account"
}

variable "workload_identity_users" {
  type        = list(string)
  default     = []
  description = "(Optional) List of members allowed to use this service account through Workload Identity, for example serviceAccount:PROJECT.svc.id.goog[NAMESPACE/KSA_NAME]"
}

variable "token_creators" {
  type        = list(string)
  default     = []
  description = "(Optional) List of members allowed to create access tokens for this service account"
}
