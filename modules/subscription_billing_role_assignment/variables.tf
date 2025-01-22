variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "principals" {}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "cloud" {}
variable "keyvaults" {}
variable "billing_role_definition_name" {
  default = "Enrollment account subscription creator"

  validation {
    condition     = contains(["Enrollment account subscription creator", "Enrollment account owner"], var.billing_role_definition_name)
    error_message = "Provide a valid Billing role defition name."
  }
}
