variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "diagnostics" {}
variable "diagnostic_profiles" {}
variable "combined_diagnostics" {}
variable "combined_resources" {
  description = "Provide a map of combined resources for environment_variables_from_resources"
  default     = {}
  type        = any
}
variable "global_settings" {}
variable "resource_group_name" {}
variable "resource_group" {
  description = "Resource group object to deploy the Azure resource"
  type        = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "container_app_environment_id" {}
