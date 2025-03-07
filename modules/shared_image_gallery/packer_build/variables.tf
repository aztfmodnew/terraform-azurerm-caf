variable "build_resource_group_name" {
  default = {}
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "global_settings" {}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "resource_group" {
  description = "Resource group object"
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "gallery_name" {}
variable "image_name" {}
variable "key_vault_id" {}
variable "tenant_id" {}
variable "subscription" {}
variable "managed_identities" {
  default = {}
}
variable "vnet_name" {
  default = {}
}
variable "subnet_name" {
  default = {}
}


