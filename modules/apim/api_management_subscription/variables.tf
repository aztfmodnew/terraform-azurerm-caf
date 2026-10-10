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
Settings for an API Management subscription. display_name is required.
Optional provider arguments include api_id, user_id, primary_key,
secondary_key, subscription_id, state, allow_tracing, and timeouts. state
defaults to submitted and allow_tracing defaults to true. Only one of api_id
and the resolved product_id may be set; if neither is set the subscription
uses the service-wide API scope. api_management, resource_group, and product
references are retained for root-module dependency resolution.
DESCRIPTION
  type = object({
    display_name    = string
    api_id          = optional(string)
    user_id         = optional(string)
    primary_key     = optional(string)
    secondary_key   = optional(string)
    subscription_id = optional(string)
    state           = optional(string, "submitted")
    allow_tracing   = optional(bool, true)
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
    product = optional(object({
      key        = optional(string)
      lz_key     = optional(string)
      product_id = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = contains([
      "active",
      "cancelled",
      "expired",
      "rejected",
      "submitted",
      "suspended"
    ], var.settings.state)
    error_message = "state must be active, cancelled, expired, rejected, submitted, or suspended."
  }

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "display_name",
      "api_id",
      "user_id",
      "primary_key",
      "secondary_key",
      "subscription_id",
      "state",
      "allow_tracing",
      "api_management",
      "resource_group",
      "resource_group_key",
      "resource_group_name",
      "product",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in API Management subscription settings."
  }
}

variable "remote_objects" {
  description = "Remote objects used by the root module to resolve API Management, resource-group, and product references."
  type        = any
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

variable "product_id" {
  description = "Optional resolved API Management product ID. Cannot be set together with settings.api_id."
  type        = string
  default     = null
}
