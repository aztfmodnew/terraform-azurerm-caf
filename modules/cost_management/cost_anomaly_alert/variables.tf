variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "base_tags" {
  description = "(Optional) Inherit tags from the resource group. Defaults to false."
  type        = bool
  default     = false
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for Azure Cost Anomaly Alert. Configuration attributes:
      - name               - (Required) Name of the alert. Must be lowercase letters, numbers, and hyphens only.
      - display_name       - (Required) Display name for the alert.
      - email_addresses    - (Required) List of email addresses to receive anomaly alerts.
      - email_subject      - (Required) Email subject. Maximum 70 characters.
      - subscription_id    - (Optional) Subscription ID scope. Defaults to provider subscription.
      - notification_email - (Optional) Email for unsubscribe requests.
      - message            - (Optional) Message body. Maximum 250 characters.
      - timeouts           - (Optional) Timeout overrides for create/read/update/delete.
    DESCRIPTION
  type = object({
    name               = string
    display_name       = string
    email_addresses    = list(string)
    email_subject      = string
    subscription_id    = optional(string)
    notification_email = optional(string)
    message            = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  validation {
    condition     = length(var.settings.email_subject) <= 70
    error_message = "settings.email_subject must be 70 characters or fewer."
  }
}
