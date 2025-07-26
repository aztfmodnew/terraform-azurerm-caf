variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "global_settings" {
  description = "Global settings object"
  type        = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "resources" {
  type = any
}
