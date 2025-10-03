variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
}

variable "client_config" {
  description = "Client configuration for Azure authentication."
  type        = any
}

variable "location" {
  description = "Specifies the Azure location where the Fabric Capacity will be deployed."
  type        = string
  default     = null
}

variable "settings" {
  description = "Configuration settings for the Fabric Capacity resource."
  type        = any
}

variable "resource_group" {
  description = "Resource group object that hosts the Fabric Capacity."
  type        = any
}

variable "base_tags" {
  description = "Flag indicating if tags should inherit from the resource group/global settings."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for cross-module dependencies."
  type        = any
  default     = {}
}
