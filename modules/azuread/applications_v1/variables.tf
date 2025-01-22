variable "global_settings" {
  default = {}
  type    = any
}
variable "settings" {
  default = {}
  type    = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "azuread_api_permissions" {
  default = {}
}
variable "user_type" {
  default = null
  type    = any
}
