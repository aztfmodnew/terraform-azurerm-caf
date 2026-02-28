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
  description = "(Required) The configuration for each module"
  type        = any
}

variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
