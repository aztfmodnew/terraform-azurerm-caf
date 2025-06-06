variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "resource_groups" {}
variable "private_endpoints" {}
variable "private_dns" {}
variable "remote_objects" {}
variable "vnet" {}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}