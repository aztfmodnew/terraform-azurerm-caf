variable "global_settings" {
  description = "Global settings object."
  type        = any
}

variable "client_config" {
  description = "Client configuration, including the current landing-zone key."
  type = object({
    landingzone_key = string
  })
}

variable "settings" {
  description = <<DESCRIPTION
Settings for associating an API Management API with a gateway. Both
api_management_gateway and api_management_api are required references; each may
provide a direct id or a local/remote key and landing-zone key. timeouts accepts
create, read, and delete. AzureRM does not support an update timeout for this
resource.
DESCRIPTION
  type = object({
    api_management_gateway = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    api_management_api = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = try(var.settings.api_management_gateway.id, null) != null || try(
      var.settings.api_management_gateway.key,
      null
    ) != null
    error_message = "api_management_gateway must provide either an id or a key reference."
  }

  validation {
    condition = try(var.settings.api_management_api.id, null) != null || try(
      var.settings.api_management_api.key,
      null
    ) != null
    error_message = "api_management_api must provide either an id or a key reference."
  }

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "api_management_gateway",
      "api_management_api",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in API Management Gateway API settings."
  }
}

variable "remote_objects" {
  description = "Remote API Management APIs and gateways used to resolve references."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
  default     = {}
}
