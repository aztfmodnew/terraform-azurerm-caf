variable "resource_id" {}

variable "name" {
  type        = string
  description = "(Required) Specifies the name. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  description = "The name of the resource group. Changing this forces a new resource to be created."
  default     = null
}
variable "resource_groups" {
  description = "The combined_objects of the resource groups. Changing this forces a new resource to be created."
  default     = {}
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = null
}

variable "subnet_id" {}
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
variable "subresource_names" {
  default = []
}
variable "client_config" {
  default = {}
}
variable "private_dns" {
  default = {}
}
variable "tags" {
  default = {}
}
