variable "global_settings" {
  description = <<DESCRIPTION
Global CAF settings, as produced by the root module. Supported attributes:
  - default_region, environment - (Optional) Default region key and environment name.
  - inherit_tags - (Optional) Whether resources inherit global tags. Defaults to false.
  - prefix, suffix, prefix_with_hyphen - (Optional) Naming prefix, suffix and hyphenated prefix.
  - prefixes, suffixes - (Optional) Naming prefix and suffix lists used by azurecaf.
  - random_length, random_seed - (Optional) Random suffix length (defaults to 0) and seed.
  - resource_types - (Optional) Additional azurecaf resource types. Defaults to [].
  - separator - (Optional) Naming separator. Defaults to "-".
  - passthrough, use_slug, clean_input - (Optional) azurecaf naming flags. Default to false, true and true.
  - regions - (Optional) Map of region keys to Azure region names.
  - tags - (Optional) Global tags.
DESCRIPTION
  type = object({
    default_region     = optional(string)
    environment        = optional(string)
    inherit_tags       = optional(bool, false)
    prefix             = optional(string)
    suffix             = optional(string)
    prefix_with_hyphen = optional(string)
    prefixes           = optional(list(string))
    suffixes           = optional(list(string))
    random_length      = optional(number, 0)
    random_seed        = optional(number)
    resource_types     = optional(list(string), [])
    separator          = optional(string, "-")
    passthrough        = optional(bool, false)
    regions            = optional(map(string))
    tags               = optional(map(string))
    use_slug           = optional(bool, true)
    clean_input        = optional(bool, true)
  })
}

variable "client_config" {
  description = <<DESCRIPTION
Client configuration, as produced by the root module. landingzone_key is required;
client_id, object_id, logged_aad_app_objectId, logged_user_objectId, subscription_id
and tenant_id are optional.
DESCRIPTION
  type = object({
    client_id               = optional(string)
    landingzone_key         = string
    logged_aad_app_objectId = optional(string)
    logged_user_objectId    = optional(string)
    object_id               = optional(string)
    subscription_id         = optional(string)
    tenant_id               = optional(string)
  })
}

variable "settings" {
  description = <<DESCRIPTION
Configure service-wide telemetry sent to the separately supplied APIM logger.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- identifier (required string): applicationinsights or azuremonitor selects the
  diagnostic destination type. applicationinsights requires an Application
  Insights logger reference. azuremonitor uses the APIM built-in
  /loggers/azuremonitor logger; the root module derives this ID when no explicit
  logger reference is supplied. Event Hub loggers cannot be attached to APIM
  service diagnostics.
- always_log_errors (optional bool): send error telemetry even when normal
  sampling would omit it.
- http_correlation_protocol (optional string): None disables correlation, Legacy
  uses legacy correlation, and W3C uses W3C distributed-tracing correlation.
- log_client_ip (optional bool): include the calling client's IP address.
- metrics_enabled (optional bool): emit request metrics to the configured
  diagnostic destination. Omission/null leaves provider handling unchanged.
- sampling_percentage (optional number): percentage of requests sampled, 0 to 100.
- verbosity (optional string): verbose, information, or error logging level.
- operation_name_format (optional string): use Name or Url as the Application
  Insights operation name. Unlike the API-specific diagnostic child, this
  module leaves omitted/null values to the provider. This value is not sent
  for other diagnostic identifiers.
- backend_request / backend_response (optional objects): capture requests sent
  to the backend and responses received from it.
- frontend_request / frontend_response (optional objects): capture requests
  received from clients and responses sent back to them.
  Each of these four direction objects accepts the identical nested structure:
  - body_bytes (optional number): number of payload bytes to record, 0 to 8192.
  - headers_to_log (optional list of strings): HTTP header names to record.
  - data_masking (optional object): redact selected telemetry values.
    query_params is an optional list of query-parameter masking rules; headers
    is an optional list of HTTP-header masking rules. Both lists default to []
    for omission or null. Each rule requires value, the parameter/header name
    to redact, and mode, which is Mask or Hide for query_params and only Mask
    for headers.
- api_management / resource_group (optional objects):
  root dependency references; all their nested fields are optional/null.
  key selects the corresponding combined CAF collection, and lz_key chooses
  its landing zone (current zone when omitted). name supplies a direct service
  or group name preferred over key. Service/group id fields are compatibility
  metadata, not used by the root's corresponding name lookups.
- api_management_logger (optional object): required for applicationinsights and
  optional for azuremonitor. id supplies a direct logger ARM ID preferred over
  key. lz_key selects the logger's landing zone. The logger name field is
  compatibility metadata. For azuremonitor, omit this block to use the built-in
  APIM logger automatically.
  resource_group_key is an optional legacy group key preferred before
  resource_group.key. The root passes resolved names/ID as separate child inputs.
- timeouts (optional object): create limits diagnostic creation, read retrieval,
  update telemetry changes, and delete removal. Each optional duration-string
  field defaults to null and leaves the provider timeout unchanged.
All other optional values default to null for provider handling. Undeclared
attributes are discarded by the settings object type.
DESCRIPTION
  type = object({
    identifier                = string
    always_log_errors         = optional(bool)
    http_correlation_protocol = optional(string)
    log_client_ip             = optional(bool)
    metrics_enabled           = optional(bool)
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
    condition = try(
      var.settings.metrics_enabled == null ||
      var.settings.identifier == "applicationinsights",
      true
    )
    error_message = "metrics_enabled is supported only for applicationinsights diagnostics."
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
  description = "The ID of the APIM logger matching the diagnostic identifier. Use /loggers/azuremonitor for azuremonitor, or an Application Insights logger for applicationinsights."
  type        = string
}
