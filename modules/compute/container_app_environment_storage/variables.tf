variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "global_settings" {}
variable "combined_resources" {
  description = "Provide a map of combined resources for environment_variables_from_resources"
  default     = {}
  type        = any
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "container_app_environment_id" {}
