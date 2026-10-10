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
Settings for an API Management API.

Required provider settings: name and revision. Optional CAF references:
resource_group_key, resource_group_name, resource_group, and api_management.
Optional provider settings: api_type, display_name, path, protocols, contact,
description, import, license, oauth2_authorization, openid_authentication,
service_url, subscription_key_parameter_names, subscription_required,
terms_of_service_url, version, version_set_id, revision_description,
version_description, source_api_id, and timeouts.

api_type accepts graphql, http, soap, or websocket and defaults to http.
protocols accepts http, https, ws, and wss. display_name, path, and protocols
are required when source_api_id is not set. service_url is required for
websocket APIs. When version is set, version_set_id must also be provided.
display_name must not be empty when supplied; an empty path is supported.
subscription_required defaults to true. See the module examples for complete
configuration patterns.
DESCRIPTION
  type = object({
    name                = string
    revision            = string
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
    api_type     = optional(string, "http")
    display_name = optional(string)
    path         = optional(string)
    protocols    = optional(list(string))
    description  = optional(string)
    contact = optional(object({
      email = optional(string)
      name  = optional(string)
      url   = optional(string)
    }))
    import = optional(object({
      content_format = string
      content_value  = string
      wsdl_selector = optional(object({
        service_name  = string
        endpoint_name = string
      }))
    }))
    license = optional(object({
      name = optional(string)
      url  = optional(string)
    }))
    oauth2_authorization = optional(object({
      authorization_server_name = string
      scope                     = optional(string)
    }))
    openid_authentication = optional(object({
      openid_provider_name         = string
      bearer_token_sending_methods = optional(list(string))
    }))
    service_url = optional(string)
    subscription_key_parameter_names = optional(object({
      header = string
      query  = string
    }))
    subscription_required = optional(bool, true)
    terms_of_service_url  = optional(string)
    version               = optional(string)
    version_set_id        = optional(string)
    revision_description  = optional(string)
    version_description   = optional(string)
    source_api_id         = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = contains(
      ["graphql", "http", "soap", "websocket"],
      var.settings.api_type
    )
    error_message = "api_type must be graphql, http, soap, or websocket."
  }

  validation {
    condition = (
      var.settings.protocols == null ||
      length(setsubtract(
        toset(coalesce(var.settings.protocols, tolist([]))),
        toset(["http", "https", "ws", "wss"])
      )) == 0
    )
    error_message = "protocols may contain only http, https, ws, and wss."
  }

  validation {
    condition = (
      var.settings.import == null ||
      contains(
        [
          "openapi",
          "openapi+json",
          "openapi+json-link",
          "openapi-link",
          "swagger-json",
          "swagger-link-json",
          "wadl-link-json",
          "wadl-xml",
          "wsdl",
          "wsdl-link"
        ],
        try(var.settings.import.content_format, "")
      )
    )
    error_message = "import.content_format must be a supported API definition format."
  }

  validation {
    condition = (
      var.settings.openid_authentication == null ||
      try(var.settings.openid_authentication.bearer_token_sending_methods, null) == null ||
      length(setsubtract(
        toset(coalesce(try(var.settings.openid_authentication.bearer_token_sending_methods, null), tolist([]))),
        toset(["authorizationHeader", "query"])
      )) == 0
    )
    error_message = "openid_authentication.bearer_token_sending_methods may contain only authorizationHeader and query."
  }

  validation {
    condition = (
      var.settings.version == null ||
      var.settings.version_set_id != null
    )
    error_message = "version_set_id must be specified when version is set."
  }

  validation {
    condition = (
      var.settings.oauth2_authorization == null ||
      var.settings.openid_authentication == null
    )
    error_message = "oauth2_authorization and openid_authentication cannot be configured together."
  }

  validation {
    condition = (
      var.settings.api_type != "websocket" ||
      var.settings.service_url != null
    )
    error_message = "service_url must be specified when api_type is websocket."
  }

  validation {
    condition = (
      var.settings.source_api_id != null ||
      (
        var.settings.display_name != null &&
        var.settings.path != null &&
        var.settings.protocols != null
      )
    )
    error_message = "display_name, path, and protocols must be specified when source_api_id is not set."
  }

  validation {
    condition     = var.settings.display_name == null || var.settings.display_name != ""
    error_message = "display_name must not be empty when specified."
  }

  validation {
    condition = (
      try(var.settings.import.wsdl_selector, null) == null ||
      contains(["wsdl", "wsdl-link"], try(var.settings.import.content_format, ""))
    )
    error_message = "import.wsdl_selector can be configured only with wsdl or wsdl-link content_format."
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

variable "api_management_name" {
  description = "Name of the API Management Service that owns this API."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the API Management Service."
  type        = string
}
