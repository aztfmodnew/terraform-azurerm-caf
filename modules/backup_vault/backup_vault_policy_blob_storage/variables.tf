variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "vault_id" {}
variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}