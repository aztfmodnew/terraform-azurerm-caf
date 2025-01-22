variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "vpn_gateway_id" {}
variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
