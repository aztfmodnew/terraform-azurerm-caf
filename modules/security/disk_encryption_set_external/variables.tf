variable "global_settings" {}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "base_tags" {
  default = {}
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "key_vault_key_id" {}
variable "resource_group_name" {}
variable "location" {}
variable "managed_identities" {}
