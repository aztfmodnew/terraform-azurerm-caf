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
Settings for the API Management diagnostic. identifier is required and accepts
applicationinsights or azuremonitor. Optional logging settings include
always_log_errors, http_correlation_protocol (None, Legacy, or W3C),
log_client_ip, sampling_percentage (0 to 100), verbosity (verbose,
information, or error), and operation_name_format (Name or Url). The four
request/response direction blocks accept body_bytes (0 to 8192), headers_to_log,
and one data_masking block. Data masking supports query_params with Mask/Hide
modes and headers with Mask mode. api_management, resource_group, and
api_management_logger are root-module dependency references. timeouts supports
create, read, update, and delete.
DESCRIPTION
  type = object({
    identifier                = string
    always_log_errors         = optional(bool)
    http_correlation_protocol = optional(string)
    log_client_ip             = optional(bool)
    sampling_percentage       = optional(number)
    verbosity                 = optional(string)
    operation_name_format     = optional(string)
    api_management            = optional(object({ id = optional(string), name = optional(string), key = optional(string), lz_key = optional(string) }))
    resource_group            = optional(object({ id = optional(string), name = optional(string), key = optional(string), lz_key = optional(string) }))
    resource_group_key        = optional(string)
    api_management_logger     = optional(object({ id = optional(string), name = optional(string), key = optional(string), lz_key = optional(string) }))
    backend_request = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(list(string))
      data_masking = optional(object({
        query_params = optional(list(object({ mode = string, value = string })), [])
        headers      = optional(list(object({ mode = string, value = string })), [])
      }))
    }))
    backend_response = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(list(string))
      data_masking = optional(object({
        query_params = optional(list(object({ mode = string, value = string })), [])
        headers      = optional(list(object({ mode = string, value = string })), [])
      }))
    }))
    frontend_request = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(list(string))
      data_masking = optional(object({
        query_params = optional(list(object({ mode = string, value = string })), [])
        headers      = optional(list(object({ mode = string, value = string })), [])
      }))
    }))
    frontend_response = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(list(string))
      data_masking = optional(object({
        query_params = optional(list(object({ mode = string, value = string })), [])
        headers      = optional(list(object({ mode = string, value = string })), [])
      }))
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = try(contains(["applicationinsights", "azuremonitor"], var.settings.identifier), false)
    error_message = "identifier must be applicationinsights or azuremonitor."
  }

  validation {
    condition     = try(var.settings.sampling_percentage >= 0 && var.settings.sampling_percentage <= 100, true)
    error_message = "sampling_percentage must be between 0 and 100."
  }

  validation {
    condition     = try(contains(["verbose", "information", "error"], var.settings.verbosity), true)
    error_message = "verbosity must be verbose, information, or error."
  }

  validation {
    condition     = try(contains(["None", "Legacy", "W3C"], var.settings.http_correlation_protocol), true)
    error_message = "http_correlation_protocol must be None, Legacy, or W3C."
  }

  validation {
    condition     = try(contains(["Name", "Url"], var.settings.operation_name_format), true)
    error_message = "operation_name_format must be Name or Url."
  }

  validation {
    condition = alltrue([
      for direction in [
        var.settings.backend_request,
        var.settings.backend_response,
        var.settings.frontend_request,
        var.settings.frontend_response
      ] : try(direction.body_bytes >= 0 && direction.body_bytes <= 8192, true)
    ])
    error_message = "body_bytes must be between 0 and 8192."
  }

  validation {
    condition = alltrue(flatten([
      for direction in [
        var.settings.backend_request,
        var.settings.backend_response,
        var.settings.frontend_request,
        var.settings.frontend_response
        ] : [
        for parameter in try(direction.data_masking.query_params, []) : contains(["Mask", "Hide"], parameter.mode)
      ]
      ])) && alltrue(flatten([
      for direction in [
        var.settings.backend_request,
        var.settings.backend_response,
        var.settings.frontend_request,
        var.settings.frontend_response
        ] : [
        for header in try(direction.data_masking.headers, []) : header.mode == "Mask"
      ]
    ]))
    error_message = "Query parameter masking mode must be Mask or Hide; header masking mode must be Mask."
  }

  validation {
    condition = length(setsubtract(keys(var.settings), [
      "identifier",
      "always_log_errors", "http_correlation_protocol", "log_client_ip",
      "sampling_percentage", "verbosity", "operation_name_format",
      "api_management", "resource_group", "resource_group_key", "api_management_logger",
      "backend_request", "backend_response", "frontend_request", "frontend_response",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in API Management diagnostic settings."
  }
}

variable "remote_objects" {
  description = "API Management services, resource groups, and loggers used for root dependency resolution."
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
  description = "The resource group containing the API Management service."
  type        = string
}

variable "api_management_logger_id" {
  description = "The ID of the API Management logger receiving diagnostic data."
  type        = string
}
