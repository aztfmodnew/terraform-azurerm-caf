variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable "primaryManagedInstanceId" {}
variable "partnerManagedInstanceId" {}
variable "partnerRegion" {}