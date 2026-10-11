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
Settings for the API Management custom-domain resource. api_management identifies
the API Management service in the root module. Endpoint settings support
developer_portal, management, portal, gateway, and scm (single objects), with
developer_portals, managements, portals, gateways, and scms for multiple endpoints.
Each endpoint requires host_name and may specify certificate plus
certificate_password, key_vault_certificate_id (a Key Vault secret URI), the
legacy key_vault_id alias, or a key_vault_certificate reference. A managed_identity
reference resolves ssl_keyvault_identity_client_id. gateway also supports
default_ssl_binding. Legacy gateways and proxy inputs accept lists or maps.
timeouts supports create, read, update, and delete.
DESCRIPTION
  type = object({
    api_management = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      id     = optional(string)
    }))

    developer_portal = optional(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    }))
    developer_portals = optional(map(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    })), {})

    management = optional(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    }))
    managements = optional(map(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    })), {})

    portal = optional(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    }))
    portals = optional(map(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    })), {})

    gateway = optional(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      certificate_request_key         = optional(string)
      lz_key                          = optional(string)
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
      default_ssl_binding             = optional(bool)
    }))
    gateways = optional(any)
    proxy    = optional(any)

    scm = optional(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      certificate_request_key         = optional(string)
      lz_key                          = optional(string)
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    }))
    scms = optional(map(object({
      host_name                       = string
      certificate                     = optional(string)
      certificate_password            = optional(string)
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      key_vault_certificate           = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      keyvault                        = optional(object({ certificate_key = optional(string), certificate_request_key = optional(string), lz_key = optional(string) }))
      certificate_request_key         = optional(string)
      lz_key                          = optional(string)
      managed_identity                = optional(object({ key = optional(string), lz_key = optional(string), client_id = optional(string) }))
      ssl_keyvault_identity_client_id = optional(string)
      negotiate_client_certificate    = optional(bool)
    })), {})

    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = alltrue([
      for value in concat(
        values(try({ for key, entry in var.settings.proxy : tostring(key) => entry }, {})),
        values(try({ for key, entry in var.settings.gateways : tostring(key) => entry }, {}))
      ) : try(value.host_name, null) != null
    ])
    error_message = "Every legacy gateways or proxy entry must define host_name."
  }
}

variable "remote_objects" {
  description = "Key Vault certificates, certificate requests, and managed identities used by endpoint settings."
  type        = any
  default     = {}
}

variable "api_management_id" {
  description = "The ID of the API Management service to configure."
  type        = string
}
