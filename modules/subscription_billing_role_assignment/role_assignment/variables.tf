variable "billing_scope_id" {}
variable "principal_id" {}
variable "role_definition_id" {}
variable "tenant_id" {}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "cloud" {}
variable "aad_user_impersonate" {
  default = null
}
