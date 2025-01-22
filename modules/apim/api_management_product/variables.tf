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
variable "api_management_name" {
  description = " The Name of the API Management Service where this subscription should be created. Changing this forces a new resource to be created."
}
variable "resource_group_name" {
  description = " The Name of the Resource Group where the API Management subscription exists. Changing this forces a new resource to be created."
}
