variable "global_settings" {
  description = "CAF global settings used for naming and tags."
  type        = any
}
variable "client_config" {
  description = "Landing-zone identity and client configuration."
  type        = any
}
variable "remote_objects" {
  description = "Combined local and remote APIM, resource-group, and backend objects used for references."
  type        = any
  default     = {}
}
variable "base_tags" {
  description = "Base tags merged with the module tag."
  type        = map(any)
  default     = {}
}

variable "settings" {
  description = "APIM backend pool composed from service child backend IDs."
  type = object({
    name                = string
    api_version         = optional(string, "2024-05-01")
    title               = optional(string)
    description         = optional(string)
    api_management_id   = optional(string)
    resource_group_name = optional(string)
    api_management = optional(object({
      id                  = optional(string)
      key                 = optional(string)
      lz_key              = optional(string)
      name                = optional(string)
      resource_group_name = optional(string)
    }))
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    services = list(object({
      id                        = optional(string)
      name                      = optional(string)
      key                       = optional(string)
      lz_key                    = optional(string)
      source                    = optional(string, "ai_backends")
      weight                    = optional(number, 100)
      priority                  = optional(number, 1)
      preferred_carbon_emission = optional(string)
    }))
    session_affinity = optional(object({
      cookie_name = string
    }))
    failure_response_status_code = optional(number)
    reconnect = optional(object({
      enabled = optional(bool, false)
      after   = optional(string, "PT2M")
    }))
    action_timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = length(var.settings.services) > 0 && length(var.settings.services) <= 30
    error_message = "An APIM backend pool requires between 1 and 30 member backends."
  }
  validation {
    condition = alltrue([
      for service in var.settings.services :
      length([
        for reference in [try(service.id, null), try(service.key, null), try(service.name, null)] :
        reference if reference != null
      ]) == 1
    ])
    error_message = "Each pool service must specify exactly one of id, key, or name."
  }
  validation {
    condition     = alltrue([for service in var.settings.services : contains(["ai_backends", "backends"], service.source)])
    error_message = "Pool service source must be ai_backends or backends."
  }
  validation {
    condition     = alltrue([for service in var.settings.services : service.weight >= 0 && service.weight <= 100 && service.priority >= 0 && service.priority <= 100])
    error_message = "Pool member weight and priority must be between 0 and 100."
  }
  validation {
    condition     = contains(["2024-05-01", "2024-06-01-preview", "2024-10-01-preview", "2025-03-01-preview", "2025-09-01-preview"], var.settings.api_version)
    error_message = "api_version must be a backends API version supported by AzAPI 2.13.0."
  }
  validation {
    condition = try(
      var.settings.failure_response_status_code >= 100 &&
      var.settings.failure_response_status_code <= 599,
      true
    )
    error_message = "failure_response_status_code must be between 100 and 599."
  }
  validation {
    condition = (
      var.settings.session_affinity == null ||
      var.settings.api_version == "2024-10-01-preview" ||
      var.settings.api_version == "2025-03-01-preview" ||
      var.settings.api_version == "2025-09-01-preview"
    )
    error_message = "session_affinity requires API version 2024-10-01-preview or later."
  }
  validation {
    condition = (
      try(var.settings.failure_response_status_code, null) == null ||
      var.settings.api_version == "2024-10-01-preview" ||
      var.settings.api_version == "2025-03-01-preview" ||
      var.settings.api_version == "2025-09-01-preview"
    )
    error_message = "failure_response_status_code requires API version 2024-10-01-preview or later."
  }
  validation {
    condition = alltrue([
      for service in var.settings.services :
      try(
        contains(["VeryLow", "Low", "Medium", "High", "VeryHigh"], service.preferred_carbon_emission),
        true
      )
    ])
    error_message = "preferred_carbon_emission must be VeryLow, Low, Medium, High, or VeryHigh."
  }
  validation {
    condition = alltrue([
      for service in var.settings.services :
      try(service.preferred_carbon_emission, null) == null ||
      var.settings.api_version == "2025-03-01-preview" ||
      var.settings.api_version == "2025-09-01-preview"
    ])
    error_message = "preferred_carbon_emission requires API version 2025-03-01-preview or later."
  }
}
