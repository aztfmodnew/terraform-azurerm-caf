variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = "Legacy managed-instance settings, with optional administrator_password_secret metadata and CRUD timeouts, plus managed_instance_lookup_timeouts.read. Secret expiration_date and not_before_date use Unix timestamps. See docs/AZAPI_MODULES.md."
  type        = any
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}
variable "inherit_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "subnet_id" {}
variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}
variable "primary_server_id" {
  default = ""
}
variable "keyvault" {}
variable "vnets" {}
variable "resource_groups" {}
variable "private_endpoints" {}
variable "private_dns" {
  default = {}
}
