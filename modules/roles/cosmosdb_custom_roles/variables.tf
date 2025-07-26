variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "account_name" {
  type = string
}
variable "assignable_scopes" {
  type = any
}
variable "permissions" {
  type = any
}
variable "role_definition_id" {
  type    = string
  default = null
}
variable "type" {
  type    = string
  default = "CustomRole"
}
variable "global_settings" {
  description = "Global settings object"
  type        = any
}
variable "settings" {
  description = "Settings object for the cosmosdb custom role"
  type        = any
}
