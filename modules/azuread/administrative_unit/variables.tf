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
    Settings for an Azure Active Directory administrative unit:
      - display_name - (Required) The display name of the administrative unit.
      - description - (Optional) A description for the administrative unit.
      - prevent_duplicate_names - (Optional) Whether to prevent creation when an administrative unit with the same name exists.
      - members - (Optional) A set of user or group object IDs managed as members. Do not use this together with the separate administrative unit member module for the same unit.
      - hidden_membership_enabled - (Optional) Whether the administrative unit and its members are hidden from public directory view.
      - timeouts - (Optional) Operation timeouts for create, read, update, and delete. Each defaults to 5 minutes.
  DESCRIPTION
  type = object({
    display_name              = string
    description               = optional(string)
    prevent_duplicate_names   = optional(bool)
    members                   = optional(set(string))
    hidden_membership_enabled = optional(bool)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
