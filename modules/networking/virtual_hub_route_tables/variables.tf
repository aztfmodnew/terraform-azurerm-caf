variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "name" {}
variable "remote_objects" {}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
}
variable "virtual_hub" {}