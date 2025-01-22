variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "global_settings" {
  type = any
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "cosmosdb_account_name" {
  type = string
}