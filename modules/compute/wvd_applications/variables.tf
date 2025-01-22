variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "global_settings" {}

variable "application_group_id" {
  default = {}
}

variable "diagnostic_profiles" {
  default = {}
}
variable "diagnostics" {}
