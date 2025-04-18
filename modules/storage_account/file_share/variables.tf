variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "storage_account_name" {}
variable "storage_account_id" {}
variable "recovery_vault" {
  default = {}
}
variable "resource_group_name" {
  default = ""
}
