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
    condition = length(setsubtract(keys(var.settings), [
      "api_management",
      "developer_portal", "developer_portals",
      "management", "managements",
      "portal", "portals",
      "gateway", "gateways", "proxy",
      "scm", "scms",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes in custom-domain settings."
  }
}

variable "remote_objects" {
  description = "Key Vault certificates, certificate requests, and managed identities used by endpoint settings."
  type        = any
  default     = {}
}

variable "base_tags" {
  description = "Base tags inherited from the resource group."
  type        = map(any)
  default     = {}
}

variable "api_management_id" {
  description = "The ID of the API Management service to configure."
  type        = string
}
