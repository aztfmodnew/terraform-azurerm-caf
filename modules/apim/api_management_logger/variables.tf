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
Settings for an API Management logger. name is required. Optional settings
include buffered (defaults to true), description, and resource_id; resource
accepts a local/remote key or direct ID as a resource_id fallback.
application_insights supports local/remote references or direct instrumentation
keys, connection strings, and identity client IDs. Configure exactly one of
connection_string or instrumentation_key; identity_client_id requires
connection_string. eventhub requires name and either connection_string or
endpoint_uri, and supports user_assigned_identity_client_id. Connection strings
are sensitive values; prefer endpoint_uri with managed identity where possible.
All four provider timeouts are configurable. api_management and resource_group
are CAF references used by the root module.
DESCRIPTION
  type = object({
    name        = string
    buffered    = optional(bool)
    description = optional(string)
    resource_id = optional(string)
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
    resource_group_key = optional(string)
    resource = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    application_insights = optional(object({
      key                 = optional(string)
      lz_key              = optional(string)
      name                = optional(string)
      instrumentation_key = optional(string)
      connection_string   = optional(string)
      identity_client_id  = optional(string)
    }))
    eventhub = optional(object({
      name                             = string
      connection_string                = optional(string)
      endpoint_uri                     = optional(string)
      user_assigned_identity_client_id = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = try(var.settings.application_insights.connection_string, null) == null || try(
      var.settings.application_insights.instrumentation_key,
      null
    ) == null
    error_message = "application_insights must not set both connection_string and instrumentation_key."
  }

  validation {
    condition = try(var.settings.application_insights.identity_client_id, null) == null || (
      try(var.settings.application_insights.instrumentation_key, null) == null &&
      (
        try(var.settings.application_insights.connection_string, null) != null ||
        try(var.settings.application_insights.key, null) != null
      )
    )
    error_message = "application_insights.identity_client_id requires a connection_string source and cannot be used with instrumentation_key."
  }

  validation {
    condition = try(var.settings.eventhub.name, null) == null || (
      try(var.settings.eventhub.connection_string, null) != null ||
      try(var.settings.eventhub.endpoint_uri, null) != null
    )
    error_message = "eventhub must set at least one of connection_string or endpoint_uri."
  }

  validation {
    condition     = var.settings.application_insights == null || var.settings.eventhub == null
    error_message = "A logger can configure either application_insights or eventhub, but not both."
  }

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "name",
      "buffered",
      "description",
      "resource_id",
      "api_management",
      "resource_group",
      "resource_group_key",
      "resource",
      "application_insights",
      "eventhub",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in API Management logger settings."
  }
}

variable "remote_objects" {
  description = "Application Insights resources and other objects used for logger references."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
  default     = {}
}

variable "resource_group_name" {
  description = "The resource group containing the API Management service."
  type        = string
}

variable "api_management_name" {
  description = "The API Management service name."
  type        = string
}
