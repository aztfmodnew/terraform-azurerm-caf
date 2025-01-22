variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = "(Required) Used to handle passthrough paramenters."
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "resource_group_name" {
  description = " The name of the Resource Group where the Log Analytics Storage Insights should exist. Changing this forces a new Log Analytics Storage Insights to be created."
}
variable "storage_account_id" {
  description = " The ID of the Storage Account used by this Log Analytics Storage Insights."
}
variable "workspace_id" {
  description = "The Workspace (or Customer) ID for the Log Analytics Workspace."
}
variable "primary_access_key" {
  description = "(Required) The storage access key to be used to connect to the storage account."
}
