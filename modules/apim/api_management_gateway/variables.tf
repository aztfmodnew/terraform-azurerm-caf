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
Settings for an API Management Gateway. name and location_data are required.
location_data.name is the required canonical location name; city, district,
and region are optional. description and all four create/read/update/delete
timeouts are optional. api_management accepts a direct id or a local/remote
key reference. resource_group and resource_group_key are accepted for
backward-compatible CAF configurations but are not arguments of this provider
resource.
DESCRIPTION
  type = object({
    name = string
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    description = optional(string)
    location_data = object({
      name     = string
      city     = optional(string)
      district = optional(string)
      region   = optional(string)
    })
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
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
    condition = try(var.settings.api_management.id, null) != null || try(
      var.settings.api_management.key,
      null
    ) != null
    error_message = "api_management must provide either an id or a key reference."
  }

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "name",
      "api_management",
      "description",
      "location_data",
      "resource_group",
      "resource_group_key",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in API Management Gateway settings."
  }
}

variable "remote_objects" {
  description = "Remote API Management objects used to resolve gateway dependencies."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
  default     = {}
}
