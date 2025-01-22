variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
# trunk-ignore(tflint/terraform_unused_declarations)
variable "global_settings" {
  type = any
}
variable "resource_group_name" {
  type = string
}
variable "gremlin_database_name" {
  type = string
}
variable "cosmosdb_account_name" {
  type = string
}