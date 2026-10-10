variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = <<DESCRIPTION
Administrative unit membership. administrative_unit_object and member_object
accept a direct id or key plus optional lz_key; when member_object.id is not
supplied, member_object.key is required and member_object.resource_type must
select either azuread_groups or azuread_users. Optional timeouts supports create,
read and delete; membership changes replace the resource.
DESCRIPTION
  type = object({
    administrative_unit_object = object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    })
    member_object = object({
      id            = optional(string)
      key           = optional(string)
      lz_key        = optional(string)
      resource_type = optional(string)
    })
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = var.settings.administrative_unit_object.id != null || var.settings.administrative_unit_object.key != null
    error_message = "settings.administrative_unit_object requires either id or key."
  }

  validation {
    condition     = var.settings.member_object.id != null || var.settings.member_object.key != null
    error_message = "settings.member_object requires either id or key."
  }

  validation {
    condition = var.settings.member_object.id != null ? true : contains(
      ["azuread_groups", "azuread_users"],
      var.settings.member_object.resource_type == null ? "" : var.settings.member_object.resource_type
    )
    error_message = "Key-based settings.member_object requires resource_type to be azuread_groups or azuread_users."
  }
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
