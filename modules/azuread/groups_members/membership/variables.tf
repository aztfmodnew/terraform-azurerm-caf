variable "group_object_id" {
  description = "The object ID of the group."
  type        = string
}

variable "member_object_id" {
  description = "The object ID of the member."
  type        = string
  default     = null
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

variable "members" {
  description = "A map of members."
  type        = map(any)
  default     = {}
}

variable "mssql_servers" {
  description = "A map of MSSQL servers."
  type        = map(any)
  default     = {}
}

variable "azuread_groups" {
  description = "A map of Azure AD groups."
  type        = map(any)
  default     = {}
}