variable "client_config" {
  description = "Client configuration object (see module README.md)."
  default     = {}
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  default     = {}
}

variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}

variable "settings" {
  description = "(Required) Used to handle passthrough parameters."
  default     = {}
}

variable "resource_group" {
  description = "Resource group object"
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}

variable "vnets" {}

variable "private_endpoints" {}

variable "private_dns" {
  default = {}
}
