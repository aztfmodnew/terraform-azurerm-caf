variable "global_settings" {
  description = "Global settings object (see module README.md)"
  type        = any
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}
variable "settings" {
  description = <<DESCRIPTION
Register a reusable backend that API policies can route requests to.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- name (required string): backend resource name processed by CAF naming.
- protocol (required string): http for an HTTP backend or soap for a SOAP backend.
- url (required string): backend host/base URL; avoid a trailing slash when
  composing backend resource paths.
- title / description (optional strings): short backend label and explanatory
  backend documentation, respectively.
- resource_id (optional string): management URI identifying the backend host,
  such as a Function/Logic App ARM ID or Service Fabric management endpoint.
- credentials (optional object): authentication and parameters sent to the host.
  authorization is an optional object: scheme names the authentication scheme
  (for example Bearer) and parameter supplies its value; both fields are optional.
  certificate is an optional list of client certificate thumbprints already
  present in APIM. header and query are optional string maps of header/query
  names to values; comma-separated values are expanded by the provider.
- proxy (optional object): outbound HTTP proxy. url is required; username and
  password are optional proxy credentials.
- tls (optional object): optional validate_certificate_chain controls server
  certificate-chain validation and optional validate_certificate_name controls
  server-name validation. Null leaves each flag to the provider.
- service_fabric_cluster (optional object): Service Fabric backend discovery.
  Required management_endpoints is the set of cluster management URLs; required
  max_partition_resolution_retries limits partition-resolution retries.
  Optional client_certificate_thumbprint or client_certificate_id authenticates
  to the management endpoint; at least one must be set. Optional
  server_certificate_thumbprints is a set of trusted server thumbprints.
  Optional server_x509_name is a set of trusted server-name objects: each
  requires name (certificate common name) and issuer_certificate_thumbprint
  (issuing certificate thumbprint).
- server_x509_name (optional object): legacy single trusted server-name object
  with the same required name and issuer_certificate_thumbprint fields. Used
  only when service_fabric_cluster.server_x509_name is null; an explicit empty
  nested set suppresses this fallback.
- circuit_breaker_rule (optional object): open the circuit after backend failures.
  Required name identifies the rule and required trip_duration gives its open
  duration as an ISO 8601 duration. Optional accept_retry_after_enabled honors
  Retry-After responses; this module defaults omission/null to false.
  Required failure_condition defines the trigger:
  - interval_duration (required string): ISO 8601 window over which failures count.
  - count (optional number): absolute threshold, 1 to 10000.
  - percentage (optional number): percentage threshold, 1 to 100.
    Exactly one of count and percentage must be set.
  - error_reasons (optional list of strings): failure categories to count.
  - status_code_range (optional list of objects, defaults to [] for omission/null):
    HTTP response ranges to count. Each requires min and max status codes from
    200 to 599, with min not greater than max. At least one non-empty error_reasons
    or status_code_range must be supplied.
- api_management / resource_group (optional objects): root parent references;
  every nested field is optional/null. name supplies a direct name preferred
  over key, key selects the corresponding combined CAF collection, and lz_key
  chooses its landing zone (current zone when omitted). id is retained metadata,
  not used for these name-based root inputs. This child receives resolved
  parent names through separate inputs.
- timeouts (optional object): create limits backend creation, read retrieval,
  update backend changes, and delete removal. Each optional duration-string
  field defaults to null, retaining its provider timeout.
Other optional values default to null. Undeclared attributes are discarded.
  DESCRIPTION
  type = object({
    name     = string
    protocol = string
    url      = string
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    resource_group = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))
    circuit_breaker_rule = optional(object({
      name                       = string
      trip_duration              = string
      accept_retry_after_enabled = optional(bool)
      failure_condition = object({
        interval_duration = string
        count             = optional(number)
        percentage        = optional(number)
        error_reasons     = optional(list(string))
        status_code_range = optional(list(object({
          min = number
          max = number
        })), [])
      })
    }))
    credentials = optional(object({
      authorization = optional(object({
        parameter = optional(string)
        scheme    = optional(string)
      }))
      certificate = optional(list(string))
      header      = optional(map(string))
      query       = optional(map(string))
    }))
    description = optional(string)
    proxy = optional(object({
      url      = string
      username = optional(string)
      password = optional(string)
    }))
    resource_id = optional(string)
    server_x509_name = optional(object({
      issuer_certificate_thumbprint = string
      name                          = string
    }))
    service_fabric_cluster = optional(object({
      client_certificate_thumbprint    = optional(string)
      client_certificate_id            = optional(string)
      management_endpoints             = set(string)
      max_partition_resolution_retries = number
      server_certificate_thumbprints   = optional(set(string))
      server_x509_name = optional(set(object({
        issuer_certificate_thumbprint = string
        name                          = string
      })))
    }))
    title = optional(string)
    tls = optional(object({
      validate_certificate_chain = optional(bool)
      validate_certificate_name  = optional(bool)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = contains(["http", "soap"], var.settings.protocol)
    error_message = "The protocol must be either http or soap."
  }

  validation {
    condition = var.settings.circuit_breaker_rule == null || (
      (try(var.settings.circuit_breaker_rule.failure_condition.count, null) != null) !=
      (try(var.settings.circuit_breaker_rule.failure_condition.percentage, null) != null)
    )
    error_message = "A circuit breaker failure_condition must set exactly one of count or percentage."
  }

  validation {
    condition = var.settings.circuit_breaker_rule == null || (
      length(coalesce(try(var.settings.circuit_breaker_rule.failure_condition.error_reasons, null), [])) > 0 ||
      length(coalesce(try(var.settings.circuit_breaker_rule.failure_condition.status_code_range, null), [])) > 0
    )
    error_message = "A circuit breaker failure_condition must set error_reasons, status_code_range, or both."
  }

  validation {
    condition = try(
      var.settings.circuit_breaker_rule.failure_condition.count == null ||
      (
        var.settings.circuit_breaker_rule.failure_condition.count >= 1 &&
        var.settings.circuit_breaker_rule.failure_condition.count <= 10000
      ),
      true
      ) && try(
      var.settings.circuit_breaker_rule.failure_condition.percentage == null ||
      (
        var.settings.circuit_breaker_rule.failure_condition.percentage >= 1 &&
        var.settings.circuit_breaker_rule.failure_condition.percentage <= 100
      ),
      true
    )
    error_message = "Circuit breaker count must be between 1 and 10000, and percentage must be between 1 and 100."
  }

  validation {
    condition = var.settings.circuit_breaker_rule == null || alltrue([
      for range in coalesce(try(var.settings.circuit_breaker_rule.failure_condition.status_code_range, null), []) :
      range.min >= 200 && range.min <= 599 &&
      range.max >= 200 && range.max <= 599 &&
      range.min <= range.max
    ])
    error_message = "Circuit breaker status code ranges must be ordered and remain between 200 and 599."
  }

  validation {
    condition = var.settings.service_fabric_cluster == null || (
      try(var.settings.service_fabric_cluster.client_certificate_id, null) != null ||
      try(var.settings.service_fabric_cluster.client_certificate_thumbprint, null) != null
    )
    error_message = "The service_fabric_cluster block must specify a client_certificate_id or client_certificate_thumbprint."
  }
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}
variable "api_management_name" {
  description = " The Name of the API Management Service where this backend should be created. Changing this forces a new resource to be created."
}
variable "resource_group_name" {
  description = " The Name of the Resource Group where the API Management Service exists. Changing this forces a new resource to be created."
}
