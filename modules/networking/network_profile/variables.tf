variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "resource_group" {}
variable "remote_objects" {}
variable "base_tags" {
  default = {}
}