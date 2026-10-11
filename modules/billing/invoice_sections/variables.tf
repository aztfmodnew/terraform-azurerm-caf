variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "base_tags" {
  description = "Enable tags inheritance from global settings."
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "The name of the resource group (for compatibility with standard pattern). Not used for invoice sections."
  type        = string
  default     = null
}

variable "resource_group" {
  description = "Resource group object (for tag inheritance)."
  type        = any
  default     = null
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for the Azure Billing Invoice Section. Configuration attributes:
      - name - (Required) The name of the invoice section.
      - billing_account_id - (Required) The billing account ID that this invoice section belongs to.
      - billing_profile_id - (Required) The billing profile ID for this invoice section.
      - labels - (Optional) Labels to attach to the invoice section.
      - tags - (Optional) Tags to assign to the invoice section.
      - display_name - (Optional) Display name; defaults to name.
      - state - (Optional) Invoice section state.
      - reason_code - (Optional) Restricted-state reason.
      - target_cloud - (Optional) Target cloud.
      - timeouts - (Optional) Create, read, update, and delete durations.
    DESCRIPTION
  type = object({
    name               = string
    billing_account_id = string
    billing_profile_id = string
    labels             = optional(map(string))
    tags               = optional(map(string))
    display_name       = optional(string)
    state              = optional(string)
    reason_code        = optional(string)
    target_cloud       = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
}
