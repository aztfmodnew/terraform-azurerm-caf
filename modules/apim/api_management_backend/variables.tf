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
    Settings for the API Management backend.

    Required attributes:
      - name - CAF naming input for the backend.
      - protocol - Backend protocol; valid values are http and soap.
      - url - Backend host URL.

    Optional attributes:
      - api_management - API Management service reference retained for root configuration compatibility.
      - resource_group - Resource group reference retained for root configuration compatibility.
      - circuit_breaker_rule - Circuit breaker settings with a required failure condition.
      - credentials - Backend authorization, certificates, headers, and query parameters.
      - description - Backend description.
      - proxy - Proxy URL and optional credentials.
      - resource_id - Management URI of the backend host in an external system.
      - service_fabric_cluster - Service Fabric management endpoints, certificates, and server names.
      - server_x509_name - Legacy single server X.509 name; use service_fabric_cluster.server_x509_name.
      - title - Backend title.
      - tls - Backend certificate validation settings.
      - timeouts - Create, read, update, and delete operation timeouts.
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
        })))
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
    condition = length(setsubtract(keys(var.settings), [
      "name", "protocol", "url", "api_management", "resource_group",
      "circuit_breaker_rule", "credentials", "description", "proxy",
      "resource_id", "server_x509_name", "service_fabric_cluster", "title", "tls", "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in settings. See the variable description for the supported API Management backend settings."
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
