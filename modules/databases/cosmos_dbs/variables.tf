variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}

variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "private_endpoints" {
  type = any
}

variable "resource_groups" {
  type = any
}

variable "private_dns" {
  default = {}
  type    = map(any)
}

variable "vnets" {
  type = any
}

variable "location" {
  description = "location of the resource if different from the resource group."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Resource group object to deploy the virtual machine"
  default     = null
  type        = string
}

variable "resource_group" {
  description = "Resource group object to deploy the virtual machine"
  type        = any
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
