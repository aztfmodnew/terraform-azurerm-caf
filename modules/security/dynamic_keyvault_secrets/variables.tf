variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
}

variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "keyvault" {}
variable "objects" {
  default = {}
}