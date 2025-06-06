variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "diagnostics" {}
variable "front_door_waf_policies" {
  default = {}
}
variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "keyvault_id" {
  default = null
}
variable "keyvault_certificate_requests" {
  default = {}
}
variable "keyvaults" {
  default = {}
}
variable "resource_group_name" {}
variable "location" {}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "tags" {
  default = {}
}

