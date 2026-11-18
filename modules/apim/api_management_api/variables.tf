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
Publish an API definition, import one, or create an API from another API.
Required settings object. Leaf values are strings unless another type is stated;
reference members are optional/null unless marked required.

- name (required string): API resource name processed by CAF naming.
- revision (required string): revision identifier; changing it creates a new API
  revision resource rather than modifying the identity of an existing revision.
- api_type (optional string): graphql, http, soap, or websocket. The module
  defaults omission/null to http.
- display_name (optional string): developer-visible API label; cannot be empty
  and is required when source_api_id is absent.
- path (optional string): relative public URL prefix identifying this API.
  The module accepts an omitted or empty path for a root-path API.
- protocols (optional list of strings): allowed client transports: http, https,
  ws, or wss. A non-empty list is required unless source_api_id is supplied.
- description (optional string): API documentation text, optionally containing HTML.
- service_url (optional string): absolute backend service URL; required for a
  websocket API.
- source_api_id (optional string): ARM ID of the API to copy, optionally suffixed
  with ;rev=<revision>. This is a direct ID, not a CAF key lookup; cloned APIs
  may omit the otherwise required display_name and protocols.
- contact (optional object): documentation contact; email is its email address,
  name the person/organization, and url an absolute contact-information URL.
  All three fields are optional.
- license (optional object): documentation license; optional name is its title
  and optional url is an absolute URL of its terms.
- import (optional object): load an API definition. Required content_format is
  openapi, openapi+json, openapi+json-link, openapi-link, swagger-json,
  swagger-link-json, wadl-link-json, wadl-xml, wsdl, or wsdl-link. Required
  content_value is document text for inline formats or an accessible document
  URL for link formats. Optional wsdl_selector limits a wsdl/wsdl-link import:
  service_name is the required WSDL service and endpoint_name the required port.
  Imported display_name, description, contact, and license can conflict with
  explicitly configured documentation fields and cause drift.
- oauth2_authorization (optional object): OAuth configuration, mutually exclusive
  with openid_authentication. Required authorization_server_name is an existing
  APIM authorization server's name, not a CAF key; optional scope identifies the
  requested operation scope.
- openid_authentication (optional object): OpenID Connect configuration. Required
  openid_provider_name is an existing APIM provider's name, not a CAF key.
  Optional bearer_token_sending_methods lists authorizationHeader and/or query;
  an empty list is accepted.
- subscription_key_parameter_names (optional object): required header names the
  HTTP subscription-key header, and required query names its query parameter.
- subscription_required (optional bool): require a subscription key. The module
  defaults omitted/null values to true; false is preserved.
- terms_of_service_url (optional string): absolute URL of API usage terms.
- version (optional string): public API version label; requires version_set_id.
- version_set_id (optional string): direct ARM ID of the associated version set.
- revision_description / version_description (optional strings): explanatory
  text for this revision and public API version, respectively.
- api_management / resource_group (optional objects): references used by the root
  to provide separate parent-name inputs. name is a direct name preferred over
  key; key selects the corresponding combined collection; lz_key selects its
  zone (current zone when omitted). resource_group_name is a legacy direct
  fallback after resource_group.name; resource_group_key is the legacy group key
  preferred before resource_group.key by root lookup.
- timeouts (optional object): create limits API creation, read retrieval, update
  API changes, and delete removal. Each field is an optional duration string;
  omission/null retains the provider timeout.
Except for api_type and subscription_required, optional fields default to null
for provider handling. Undeclared attributes are discarded by the settings type.
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
    condition = var.settings.source_api_id != null ? true : (
      var.settings.display_name != null && var.settings.protocols != null ? length(var.settings.protocols) > 0 : false
    )
    error_message = "display_name and at least one protocol must be specified when source_api_id is not set."
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
