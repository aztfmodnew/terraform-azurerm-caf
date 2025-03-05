variable "global_settings" {
  description = "Global settings object"
  type        = any
}

variable "client_config" {
  description = "Client configuration object"
  type        = any
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "settings" {
  description = "Settings of the module"
  type        = any
}

variable "resource_group" {
  description = "Resource group object"
  type        = any
}

variable "base_tags" {
  type        = bool
  description = "Flag to determine if tags should be inherited"
}

variable "remote_objects" {
  type        = any
  description = "Remote objects"
}
