variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "global_settings" {}
variable "location" {
  description = "location of the resource if different from the resource group."
  type        = string
  default     = null
}
variable "resource_group_name" {
  description = "Resource group object to deploy the Azure resource"
  type        = string
  default     = null
}
variable "resource_group" {
  description = "Resource group object to deploy the Azure resource"
  type        = any
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = bool
}
variable "wvd_host_pools" {
  default = {}
}
variable "name" {
  default = {}
}
variable "host_pool_id" {
  default = {}
}
variable "workspace_id" {
  default = {}
}

variable "key_vault_id" {
  default = {}
}

variable "diagnostic_profiles" {
  default = {}
}
variable "diagnostics" {}
