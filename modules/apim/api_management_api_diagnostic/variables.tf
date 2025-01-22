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
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}
variable "api_management_logger_id" {
  description = " The ID (name) of the Diagnostics Logger."
}
variable "api_management_name" {
  description = " The name of the API Management Service instance. Changing this forces a new API Management Service API Diagnostics Logs to be created."
}
variable "api_name" {
  description = " The name of the API in the API Management Service instance. Changing this forces a new API Management Service API Diagnostics Logs to be created."
}
variable "resource_group_name" {
  description = " The name of the Resource Group where the API Management Service API Diagnostics Logs should exist. Changing this forces a new API Management Service API Diagnostics Logs to be created."
}
