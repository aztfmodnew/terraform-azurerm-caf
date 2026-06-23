variable "settings" {
  description = "Optional normalized settings object for the Digital Twins Instance module. When provided, values override the legacy flat inputs."
  type        = any
  default     = {}
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "tags" {
  description = "(Required) map of tags for the Digital Twins Instance"
  type        = any
  default     = null
}

variable "name" {
  description = "(Required) Name of the Digital Twins Instance"
  type        = string
  default     = null
}

variable "location" {
  description = "(Required) Resource Location"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "(Required) Resource group of the Digital Twins Instance"
  type        = string
  default     = null
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}

variable "remote_objects" {
  description = "Remote objects configuration used for dependency resolution."
  type        = any
  default     = {}
}

variable "identity" {
  description = "(Optional) Managed identity configuration for the Digital Twins Instance."
  type = object({
    type                  = string
    identity_ids          = optional(list(string), [])
    managed_identity_ids  = optional(list(string), [])
    managed_identity_keys = optional(list(string), [])
    remote = optional(map(object({
      managed_identity_keys = list(string)
    })), {})
  })
  default = null
}

variable "timeouts" {
  description = "(Optional) Timeouts for the Digital Twins Instance operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
