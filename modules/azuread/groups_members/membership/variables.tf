variable "group_object_id" {
  description = "The object ID of the group."
  type        = string
}

variable "timeouts" {
  description = "Optional create, read and delete timeouts applied to each membership."
  type = object({
    create = optional(string)
    read   = optional(string)
    delete = optional(string)
  })
  default = null
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
  description = "Member keys with optional source/destination landing-zone keys and timeout metadata."
  type = object({
    keys         = optional(list(string), [])
    lz_key       = optional(string)
    group_lz_key = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  })
  default = {}
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