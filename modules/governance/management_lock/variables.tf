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
    Settings object for Azure Management Lock. Configuration attributes:
      - name       - (Required) Name of the management lock.
      - scope      - (Required) Scope at which the lock should be created (subscription, resource group, or resource ID).
      - lock_level - (Required) Lock level. Possible values: CanNotDelete, ReadOnly.
      - notes      - (Optional) Description notes. Maximum 512 characters. Forces new resource on change.
      - timeouts   - (Optional) Timeout overrides for create/read/delete.
    DESCRIPTION
  type = object({
    name       = string
    scope      = string
    lock_level = string
    notes      = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  })
  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.settings.lock_level)
    error_message = "settings.lock_level must be either 'CanNotDelete' or 'ReadOnly'."
  }
}
