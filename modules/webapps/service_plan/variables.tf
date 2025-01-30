variable "location" {
  description = "(Required) Resource Location"
  type        = string
  default     = null
}

variable "resource_group" {
  description = "Resource group object to deploy the Azure resource"
  type        = any
}

variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects to be used in the module"
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)"
  type        = any
}