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
accept a direct id or key plus optional lz_key; member_object.resource_type
selects the remote object collection. Optional timeouts supports create,
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
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
