variable "global_settings" {}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "keyvaults" {}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
