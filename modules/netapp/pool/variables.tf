variable "global_settings" {}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "resource_group_name" {}
variable "location" {}
variable "account_name" {}
variable "vnets" {}

variable "base_tags" {
  default = {}
}