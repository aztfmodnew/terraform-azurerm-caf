variable "global_settings" {}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "resource_group_name" {
  description = "Deprecated fallback: resource group name of the Event Hub Namespace. If namespace_id is not provided, this is used to look up the namespace ID."
  type        = string
  default     = null
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "namespace_id" {
  description = "The ID of an existing Event Hub Namespace. Use namespace = { id = ... } when the ID is computed during apply."
  type        = string
  default     = null
}
variable "namespace" {
  description = "Namespace reference containing its ARM ID. The object allows computed IDs without an unknown lookup count and takes precedence over namespace_id."
  type        = object({ id = string })
  default     = null
}
variable "namespace_name" {
  description = "Deprecated fallback: name of the Event Hub Namespace. If namespace_id is not provided, this is used to look up the namespace ID."
  type        = string
  default     = null
}
variable "storage_account_id" {
  description = "Identifier of the storage account ID to be used."
  type        = string
}
