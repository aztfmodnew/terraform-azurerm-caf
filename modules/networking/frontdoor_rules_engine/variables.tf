variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
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
variable "frontdoor_name" {
  description = " The name of the Front Door instance. Changing this forces a new resource to be created."
}
variable "resource_group_name" {
  description = " The name of the resource group. Changing this forces a new resource to be created."
}
