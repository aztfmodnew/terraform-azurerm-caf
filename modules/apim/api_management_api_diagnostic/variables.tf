variable "global_settings" {
  description = "Global settings object (see module README.md)."
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Settings for API Management API diagnostics.

Required: identifier. Optional CAF references: api_management, api,
api_management_logger, resource_group_key, resource_group_name, and
resource_group. Optional diagnostic options: always_log_errors,
backend_request, backend_response, frontend_request, frontend_response,
http_correlation_protocol, log_client_ip, sampling_percentage, verbosity,
operation_name_format, and timeouts.

identifier accepts applicationinsights or azuremonitor. Sampling percentage is
between 0 and 100. Verbosity accepts verbose, information, or error.
http_correlation_protocol accepts None, Legacy, or W3C. operation_name_format
accepts Name or Url and defaults to Name. Each request/response block can
configure body_bytes (up to 8192), headers_to_log, and a data_masking block.
Data masking accepts lists of query_params (Mask or Hide) and headers (Mask).
DESCRIPTION
  type = object({
    identifier          = string
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    api_management_logger = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      id     = optional(string)
    }))
    always_log_errors         = optional(bool)
    http_correlation_protocol = optional(string)
    log_client_ip             = optional(bool)
    sampling_percentage       = optional(number)
    verbosity                 = optional(string)
    operation_name_format     = optional(string, "Name")
    backend_request = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(set(string))
      data_masking = optional(object({
        query_params = optional(list(object({
          mode  = string
          value = string
        })), [])
        headers = optional(list(object({
          mode  = string
          value = string
        })), [])
      }))
    }))
    backend_response = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(set(string))
      data_masking = optional(object({
        query_params = optional(list(object({
          mode  = string
          value = string
        })), [])
        headers = optional(list(object({
          mode  = string
          value = string
        })), [])
      }))
    }))
    frontend_request = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(set(string))
      data_masking = optional(object({
        query_params = optional(list(object({
          mode  = string
          value = string
        })), [])
        headers = optional(list(object({
          mode  = string
          value = string
        })), [])
      }))
    }))
    frontend_response = optional(object({
      body_bytes     = optional(number)
      headers_to_log = optional(set(string))
      data_masking = optional(object({
        query_params = optional(list(object({
          mode  = string
          value = string
        })), [])
        headers = optional(list(object({
          mode  = string
          value = string
        })), [])
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
    condition     = contains(["applicationinsights", "azuremonitor"], var.settings.identifier)
    error_message = "identifier must be applicationinsights or azuremonitor."
  }

  validation {
    condition = (
      var.settings.sampling_percentage == null ||
      (var.settings.sampling_percentage >= 0 && var.settings.sampling_percentage <= 100)
    )
    error_message = "sampling_percentage must be between 0 and 100."
  }

  validation {
    condition     = var.settings.verbosity == null || contains(["verbose", "information", "error"], var.settings.verbosity)
    error_message = "verbosity must be verbose, information, or error."
  }

  validation {
    condition     = var.settings.http_correlation_protocol == null || contains(["None", "Legacy", "W3C"], var.settings.http_correlation_protocol)
    error_message = "http_correlation_protocol must be None, Legacy, or W3C."
  }

  validation {
    condition     = contains(["Name", "Url"], var.settings.operation_name_format)
    error_message = "operation_name_format must be Name or Url."
  }
}

variable "remote_objects" {
  description = "Remote objects used to resolve API Management dependencies."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}

variable "api_management_logger_id" {
  description = "ID of the API Management diagnostics logger."
  type        = string
}

variable "api_management_name" {
  description = "Name of the API Management Service containing the API."
  type        = string
}

variable "api_name" {
  description = "Name of the API whose diagnostics are configured."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the API Management Service."
  type        = string
}
