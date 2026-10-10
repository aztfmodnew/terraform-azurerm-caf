variable "global_settings" {
  description = "Global settings object used by the API Management configuration."
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
Settings for an API Management user. user_id, email, first_name, and last_name
are required. Optional settings are confirmation (invite or signup), note,
password, state (active, blocked, or pending), and create/read/update/delete
timeouts. AzureRM treats password as sensitive. The api_management and
resource_group references are retained for root-module dependency resolution.
The provider allows a pending user to become active or blocked, but not the
reverse transition.
DESCRIPTION
  type = object({
    user_id      = string
    email        = string
    first_name   = string
    last_name    = string
    confirmation = optional(string)
    note         = optional(string)
    password     = optional(string)
    state        = optional(string)
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = var.settings.confirmation == null ? true : contains([
      "invite",
      "signup"
    ], var.settings.confirmation)
    error_message = "confirmation must be invite or signup."
  }

  validation {
    condition = var.settings.state == null ? true : contains([
      "active",
      "blocked",
      "pending"
    ], var.settings.state)
    error_message = "state must be active, blocked, or pending."
  }

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "user_id",
      "email",
      "first_name",
      "last_name",
      "confirmation",
      "note",
      "password",
      "state",
      "api_management",
      "resource_group",
      "resource_group_key",
      "resource_group_name",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in API Management user settings."
  }
}

variable "remote_objects" {
  description = "Remote objects used by the root module to resolve API Management and resource-group references."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
  default     = {}
}

variable "api_management_name" {
  description = "The name of the API Management service."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group containing the API Management service."
  type        = string
}
