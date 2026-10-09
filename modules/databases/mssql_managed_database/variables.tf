variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "server_name" {}
variable "settings" {
  description = "Managed database settings retaining the legacy CamelCase ARM parameters, with optional cross-subscription restore/storage/ledger settings, deployment controls, and CRUD timeouts. See docs/AZAPI_MODULES.md."
  type        = any
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}
variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}
variable "sourceDatabaseId" {
  default = ""
}
variable "resource_group_id" {

}