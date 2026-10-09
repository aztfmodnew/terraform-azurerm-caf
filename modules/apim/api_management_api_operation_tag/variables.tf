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
    Settings for the API Management API operation tag.

    Required attributes:
      - name - CAF naming input for the API operation tag.
      - display_name - Display name of the API operation tag.

    Optional attributes:
      - api_operation - Operation reference retained for compatibility with the root configuration.
      - timeouts - Create, read, update, and delete operation timeouts.
  DESCRIPTION
  type = object({
    name         = string
    display_name = string
    api_operation = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "name", "display_name", "api_operation", "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in settings. Allowed: name, display_name, api_operation, timeouts."
  }
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}
variable "api_operation_id" {
  description = "The ID of the API Management API Operation Tag."
  type        = string
}
