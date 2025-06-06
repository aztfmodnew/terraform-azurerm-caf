variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}
variable "resource_group_name" {
  description = "Name of the existing resource group to deploy the virtual machine"
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "tags" {
  default = null
}
variable "vnets" {
  default = null
  type    = any
}
variable "pips" {
  default = null
}
variable "private_endpoints" {}
variable "combined_resources" {
  description = "Provide a map of combined resources for environment_variables_from_resources"
  default     = {}
  type        = any
}
