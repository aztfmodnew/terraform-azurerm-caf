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

variable "resource_group_name" {
  description = "(Required) Resource group of the IoT Hub DPS"
}

variable "resource_group" {
  description = "Resource group object to deploy the IoT Hub DPS"
}

variable "location" {
  description = "(Required) Region in which the resource will be deployed"
}

variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
