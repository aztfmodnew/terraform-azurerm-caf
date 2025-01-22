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
variable "resource_group_name" {
  description = " The name of the resource group in which to create the resource."
}
variable "backend_address_pool_ids" {
  description = "A list of reference to a Backend Address Pool over which this Load Balancing Rule operates."
}
variable "probe_id" {
  description = "A reference to a Probe used by this Load Balancing Rule."
}
