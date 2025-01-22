variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "group_id" {
  default = null
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "group_key" {
  default = null
}
variable "azuread_groups" {
  default = {}
}
variable "azuread_apps" {
  default = {}
}
variable "azuread_service_principals" {
  default = {}
}
variable "managed_identities" {
  default = {}
}
variable "mssql_servers" {
  default = {}
}