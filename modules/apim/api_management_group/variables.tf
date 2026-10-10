variable "global_settings" {
  description = "Global settings used by CAF naming."
  type = object({
    prefixes      = list(string)
    random_length = number
    passthrough   = bool
    use_slug      = bool
  })
}

variable "client_config" {
  description = "Client configuration, including the current landing-zone key."
  type = object({
    landingzone_key = string
  })
}

variable "settings" {
  description = <<DESCRIPTION
Settings for an API Management group. name, display_name, and references to
api_management and resource_group are required. Dependency references support
direct names or local/remote keys. description and external_id are optional;
external_id is typically an Entra group reference such as aad://<tenant>/groups/<object-id>.
type accepts custom, external, or system and defaults to the provider's custom
value. All four provider timeouts are configurable. resource_group_key is
retained as a fallback for legacy CAF configurations.
DESCRIPTION
  type = object({
    name         = string
    display_name = string
    description  = optional(string)
    external_id  = optional(string)
    type         = optional(string)
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
      id     = optional(string)
    }))
    resource_group_key = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = try(contains(["custom", "external", "system"], var.settings.type), true)
    error_message = "type must be custom, external, or system."
  }

  validation {
    condition = try(var.settings.api_management.key, null) != null || try(
      var.settings.api_management.name,
      null
    ) != null
    error_message = "api_management must provide either a key reference or a direct name."
  }

  validation {
    condition = try(var.settings.resource_group.key, null) != null || try(
      var.settings.resource_group.name,
      null
    ) != null || try(var.settings.resource_group_key, null) != null
    error_message = "resource_group must provide a key, a direct name, or the legacy resource_group_key."
  }

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "name",
      "display_name",
      "description",
      "external_id",
      "type",
      "api_management",
      "resource_group",
      "resource_group_key",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in API Management group settings."
  }
}

variable "remote_objects" {
  description = "Remote API Management services and resource groups used to resolve references."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
  default     = {}
}
