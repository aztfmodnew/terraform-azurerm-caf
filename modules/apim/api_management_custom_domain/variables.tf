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
Manage custom endpoint hostnames on the service supplied by api_management_id.
The settings object itself is required; reference members are optional/null
unless explicitly marked required.
Do not also manage inline hostname_configuration on that same service.

- api_management (optional object): root service reference. Optional id is a
  direct service ARM ID preferred over optional key, which selects the combined
  service collection. Optional lz_key selects its zone (current by default).
  This child uses the separate resolved api_management_id input.
- developer_portal / developer_portals: optional single endpoint / map of
  endpoints for the current developer portal.
- management / managements: optional single endpoint / map for the management API.
- portal / portals: optional single endpoint / map for the legacy publisher portal.
- gateway / gateways: optional single endpoint / legacy collection for API traffic.
- scm / scms: optional single endpoint / map for source-control access.
  Single endpoint objects default to null. The typed plural maps default to {}
  for omission/null and use caller-chosen labels as keys. Each singular object
  is merged under key default, overriding a plural entry with that same key.
  gateways and proxy are optional legacy lists or maps of gateway endpoints,
  defaulting to null. A non-null proxy selects that collection instead of
  gateways, even if proxy is empty; the singular gateway is then merged last.

The following common endpoint structure applies to developer_portal,
developer_portals.*, management, managements.*, portal, portals.*, gateway,
every gateways/proxy entry, scm, and scms.*. Leaf fields are strings unless
explicitly identified as booleans or nested objects:
- host_name (required): DNS hostname bound to the corresponding endpoint.
- certificate (optional sensitive string): base64-encoded certificate material.
- certificate_password (optional sensitive string): password protecting it.
- key_vault_certificate_id (optional): Key Vault secret URI containing the
  endpoint PKCS#12 certificate (application/x-pkcs12), not a vault or certificate
  ARM ID.
- key_vault_id (optional): legacy alias for that same certificate secret URI.
- key_vault_certificate (optional object): managed certificate reference.
  Optional certificate_key selects remote_objects.keyvault_certificates;
  optional certificate_request_key selects keyvault_certificate_requests.
  Optional lz_key selects the referenced zone and defaults to the current zone.
  The selected object's secret_id becomes the certificate secret URI.
- keyvault (optional object): legacy reference with the same optional
  certificate_key, certificate_request_key, and lz_key fields and meanings.
  Certificate-source precedence is direct key_vault_certificate_id, direct
  key_vault_id, current certificate reference, current certificate-request
  reference, legacy certificate reference, then legacy request reference.
  Use a Key Vault certificate source or inline certificate/password as required
  by the provider. Versionless secret URIs allow automatic certificate updates.
- negotiate_client_certificate (optional bool): request client-certificate
  negotiation on this hostname. Null leaves the provider default of false.
- ssl_keyvault_identity_client_id (optional): direct managed-identity client ID
  used to retrieve the certificate from Key Vault.
- managed_identity (optional object): optional key selects
  remote_objects.managed_identities[lz_key][key].client_id; optional lz_key defaults
  to the current zone. Optional client_id is retained metadata but is not read
  by this lookup; use ssl_keyvault_identity_client_id for a direct client ID.
  The direct ssl_keyvault_identity_client_id wins over a key lookup. The identity
  must be assigned to APIM and authorized to read the certificate secret.

Additional endpoint fields:
- gateway.default_ssl_binding and that field on gateways/proxy entries (optional
  bool): use this certificate when a client supplies no SNI hostname. Null
  leaves the provider default of false.
  Do not add the default gateway hostname ending in .azure-api.net; Azure
  creates it automatically.
- gateway.certificate_request_key, scm.certificate_request_key, and
  scms.*.certificate_request_key (optional): legacy final fallback request key,
  used after the certificate sources above. Their optional lz_key selects the
  request's zone, defaulting to the current zone.
- timeouts (optional object): create limits domain configuration, read retrieval,
  update hostname/certificate changes, and delete removal. create, read, update,
  and delete are optional duration strings; null preserves provider timeouts.
Unless a collection default is stated, optional fields default to null; required
endpoint fields are required only when that endpoint is configured. Undeclared
attributes in typed objects are discarded; legacy any-typed collections retain
their entries for the compatibility logic.
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
