variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "subnet_id" {}
variable "location" {
  description = "(Required) Resource Location"
  default     = null
}
variable "resource_group_name" {
  description = "Resource group object to deploy the Azure resource"
  type        = string
  default     = null
}
variable "resource_group" {
  description = "Resource group object to deploy the Azure resource"
  type        = any
}
variable "private_dns" {
  default = {}
}
variable "diagnostics" {
  default = null
}
variable "diagnostic_profiles" {
  default = null
}
