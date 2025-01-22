variable "name" {
  default = null
  type    = string
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "resource_groups" {
  default = {}
  type    = map(any)
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "remote_objects" {
  type = any
}
