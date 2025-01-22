variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "remote_objects" {}
variable "route_table_id" {}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}