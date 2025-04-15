variable "settings" {
  description = "The settings for the Azure resource."
  type        = any
}

variable "group_id" {
  description = "The ID of the group."
  type        = string
  default     = null
}

variable "group_object_id" {
  description = "The object ID of the group."
  type        = string
  default     = null
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "group_key" {
  description = "The key of the group."
  type        = string
  default     = null
}

variable "azuread_groups" {
  description = "A map of Azure AD groups."
  type        = map(any)
  default     = {}
}

variable "azuread_apps" {
  description = "A map of Azure AD applications."
  type        = map(any)
  default     = {}
}

variable "azuread_service_principals" {
  description = "A map of Azure AD service principals."
  type        = map(any)
  default     = {}
}

variable "managed_identities" {
  description = "A map of managed identities."
  type        = map(any)
  default     = {}
}

variable "mssql_servers" {
  description = "A map of MSSQL servers."
  type        = map(any)
  default     = {}
}