variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}
variable "tags" {
  default = {}
}
variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "front_door_waf_policies" {
  default = {}
}

