variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}
variable "admin_group_object_ids" {}
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
variable "diagnostic_profiles" {
  default = {}
}
variable "private_dns_zone_id" {
  default = null
}

variable "private_endpoints" {
  default = {}
}
variable "private_dns" {
  default = {}
}

variable "remote_objects" {
  default = {}
}
