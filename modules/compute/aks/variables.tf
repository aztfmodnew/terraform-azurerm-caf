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
variable "admin_group_object_ids" {
  description = "Admin group object ids to be used in the module."
  default     = []
  type        = list(string)
}
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
  description = "Diagnostic settings for the resource."
  default     = {}
  type        = any
}
variable "private_dns_zone_id" {
  description = "Private DNS zone id to be used in the module."
  default     = null
  type        = string
}

variable "private_endpoints" {
  description = "Private endpoints to be used in the module."
  default     = {}
  type        = any
}
variable "private_dns" {
  description = "Private DNS zones to be used in the module."
  default     = {}
  type        = any
}

variable "remote_objects" {
  description = "Remote objects to be used in the module."
  default     = {}
  type        = any
}
