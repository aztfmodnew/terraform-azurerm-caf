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
Configure telemetry for one API using the separately supplied APIM logger ID.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- identifier (required string): must be applicationinsights. AzureRM 5.14
  internally defaults operation_name_format for this resource and rejects
  azuremonitor even when that attribute is omitted. Service diagnostics can
  continue to use azuremonitor; this constraint applies only to API
  diagnostics.
- always_log_errors (optional bool): send error telemetry regardless of sampling.
- http_correlation_protocol (optional string): None disables correlation, Legacy
  uses legacy correlation, and W3C uses W3C distributed-tracing correlation.
- log_client_ip (optional bool): include the calling client's IP address.
- metrics_enabled (optional bool): emit request metrics to the configured
  diagnostic destination. Omission/null leaves provider handling unchanged.
- sampling_percentage (optional number): percentage of requests sampled, 0 to 100.
- verbosity (optional string): verbose, information, or error logging level.
- operation_name_format (optional string): use the operation Name or Url in
  Application Insights telemetry. Omission/null leaves the provider default in
  place.
- backend_request / backend_response (optional objects): logging for traffic
  sent to the backend and responses received from it, respectively.
- frontend_request / frontend_response (optional objects): logging for client
  requests received by the gateway and responses returned to clients.
  All four direction objects share these fields:
  - body_bytes (optional number): payload bytes captured, from 0 to 8192.
  - headers_to_log (optional set of strings): names of HTTP headers to capture.
  - data_masking (optional object): redact selected values before telemetry is
    written. query_params is an optional list of query-parameter rules; headers
    is an optional list of HTTP-header rules. Both lists default to [] even
    when explicitly null. In every rule, required value is the parameter/header
    name (not its secret value). Required mode is Mask or Hide for query_params;
    for headers it must be Mask.
- api_management / api / resource_group (optional objects): root parent-name
  references. Every nested field is optional/null: name is a direct name
  preferred over key, key selects the corresponding combined CAF collection,
  and lz_key selects its zone (current zone when omitted). resource_group_key
  is the optional legacy group key preferred before resource_group.key.
  resource_group_name is retained compatibility metadata; the existing root
  diagnostic call resolves resource_group.name or a key, not this field.
- api_management_logger (optional object): root logger reference. Optional id
  is the direct logger ARM ID preferred over optional key, which selects the
  combined logger collection; optional lz_key selects its zone, defaulting to
  the current zone. The root supplies separate name/ID inputs to this child.
- timeouts (optional object): create limits diagnostic creation, read retrieval,
  update logging changes, and delete removal. Each optional duration-string
  field defaults to null, retaining its provider timeout.
Other optional values remain null for provider handling. Undeclared attributes
are discarded by the settings object type.
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
    metrics_enabled           = optional(bool)
    sampling_percentage       = optional(number)
    verbosity                 = optional(string)
    operation_name_format     = optional(string)
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
    condition     = var.settings.identifier == "applicationinsights"
    error_message = "identifier must be applicationinsights for API diagnostics with AzureRM 5.14; use azuremonitor only with the service diagnostic module."
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
    condition     = var.settings.operation_name_format == null || contains(["Name", "Url"], var.settings.operation_name_format)
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
