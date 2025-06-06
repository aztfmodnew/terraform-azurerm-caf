variable "global_settings" {}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "resource_group_name" {
  description = "Resource group name."
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "namespace_name" {
  description = "Name of the Event Hub Namespace."
  type        = string
}
variable "storage_account_id" {
  description = "Identifier of the storage account ID to be used."
  type        = string
}
