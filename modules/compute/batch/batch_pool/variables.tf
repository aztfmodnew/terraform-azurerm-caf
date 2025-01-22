variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "batch_account" {}
variable "managed_identities" {
  default = {}
}
variable "batch_certificates" {
  default = {}
}
variable "vnets" {
  default = {}
}
