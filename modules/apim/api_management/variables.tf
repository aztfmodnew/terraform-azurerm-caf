variable "global_settings" {
  description = "Global settings object (see module README.md)."
  type        = any
}

variable "vnets" {
  description = "Virtual network configuration used to resolve subnet references."
  type        = any
}

variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Deploy an API Management service, its regional gateways, identities, portal
behavior, certificates, and transport settings. Leaf values are strings unless
another type is stated. Optional fields default to null for provider handling
unless a module default or lookup fallback is explicitly described.
The settings object itself is required; reference members are optional/null
unless explicitly marked required.

- name (required): service name processed by CAF naming.
- publisher_name / publisher_email (required): publisher/company name and its
  contact email address.
- sku_name (required): tier_capacity, for example Developer_1. Tiers are
  Consumption, Developer, Basic, BasicV2, Standard, StandardV2, Premium, and
  PremiumV2. Capacity is a positive integer except Consumption_0.
- region (optional): key in global_settings.regions resolved by the root into
  the separate location input.
- resource_group (optional object): root group reference; optional name is its
  direct name, optional key its combined CAF collection key, and optional lz_key
  its landing-zone key (current zone when omitted). resource_group_name is a
  legacy direct-name fallback; resource_group_key is the legacy key preferred
  before resource_group.key in the root group lookup. The child itself uses
  separate resource_group and resource_group_name inputs, not these settings.
- client_certificate_enabled (optional bool): require a client certificate on
  gateway requests; supported for the Consumption tier.
- gateway_disabled (optional bool): disable the main-region gateway; requires
  a service deployed with additional locations.
- min_api_version (optional): oldest permitted control-plane API version.
- notification_sender_email (optional): sender address for service notifications.
- zones (optional list of strings): availability zone identifiers; provider
  documentation limits zone support to Premium.
- public_network_access_enabled (optional bool): allow public management-plane
  access. The module defaults omission/null to true, required during creation;
  this does not independently control API gateway/developer-portal exposure.
- public_ip_address_id (optional): direct standard-SKU IPv4 public-IP ARM ID,
  preferred over public_ip_address (optional object). In that object, required
  key selects public_ip_addresses[lz_key][key].id and optional lz_key defaults
  to the current zone. Custom IPs require a supported VNet-integrated tier.
- virtual_network_type (optional): None, External, or Internal; the module
  defaults omission/null to None.
- virtual_network_configuration (optional object): subnet attachment, required
  for External/Internal networking. Optional subnet_id is a direct subnet ARM
  ID and wins over a key lookup. Otherwise optional vnet_key and subnet_key
  identify vnets[lz_key][vnet_key].subnets[subnet_key].id; optional lz_key defaults
  to the current zone. A subnet must resolve when this block is configured.
- additional_location (optional object): legacy single extra region.
- additional_locations (optional map, defaults to {}): additional regions keyed
  by stable caller labels. Entries are appended after additional_location.
  Both forms have identical fields: required location names the Azure region;
  optional capacity (number) is its compute-unit count, provider-defaulted from
  the primary region; optional zones (list of strings) selects regional zones;
  optional gateway_disabled (bool) disables that regional gateway; optional
  public_ip_address_id supplies a direct standard-SKU IPv4 public-IP ID.
  Optional virtual_network_configuration has the same optional subnet_id,
  vnet_key, subnet_key, and lz_key fields and direct-ID-first resolution as the
  primary block. Regional zone/custom-IP support is tier-dependent.
- certificate (optional object): legacy single certificate for a service store.
- certificates (optional map, defaults to {}): additional store certificates;
  entries are appended after certificate, with at most ten total. Both forms
  require encoded_certificate (sensitive base64 PFX/X.509 data) and store_name
  (CertificateAuthority or Root); optional certificate_password unlocks the
  certificate. These store certificates are separate from hostname bindings.
- identity (optional object): required type is SystemAssigned, UserAssigned, or
  SystemAssigned, UserAssigned. Optional identity_ids (list of ARM IDs) takes
  precedence over resolved CAF identities, including when explicitly [].
  Optional managed_identity_keys (list, defaults to []) resolves identities in
  remote_objects.managed_identities[current zone]. Optional remote (map,
  defaults to {}) is keyed by landing zone; each value requires a
  managed_identity_keys list to resolve in that zone. The local and remote IDs
  are concatenated when identity_ids is null. UserAssigned modes require
  assigned user identities.
- hostname_configuration (optional object): inline bindings; do not combine
  with a separate custom-domain resource on the same service.
  management targets the management API; portal the legacy publisher portal;
  developer_portal the current developer portal; proxy the API gateway; scm
  source-control access. Each is an optional single endpoint. managements,
  portals, developer_portals, proxies, and scms are optional maps of the same
  endpoints, each defaulting to {}. Each map is appended to its singular endpoint.
  Legacy top-level management, portal, developer_portal, proxy, and scm objects
  supply the singular endpoint only when the corresponding nested singular
  object is null. The parent hostname_configuration must still be configured.
  The following common endpoint fields apply to every singular, map entry,
  and top-level alias:
  - host_name (required): endpoint DNS name.
  - key_vault_certificate_id (optional): PKCS#12 certificate secret URI, not a
    vault/certificate ARM ID; a versionless URI allows automatic renewal.
  - key_vault_id (optional): legacy secret-URI alias, lower precedence than
    key_vault_certificate_id. Inline bindings do not resolve CAF certificate keys.
  - certificate / certificate_password (optional sensitive strings): inline
    base64 certificate and its password, as an alternative to Key Vault.
  - negotiate_client_certificate (optional bool): negotiate client certificates;
    null leaves the provider default of false.
  - ssl_keyvault_identity_client_id (optional): client ID of the service's
    assigned identity authorized to read the certificate secret.
  Only proxy, proxies.*, and the top-level proxy alias additionally accept
  optional default_ssl_binding (bool): use the binding for clients without SNI;
  null leaves the provider default of false.
- delegation (optional object): external account/subscription workflows.
  Optional subscriptions_enabled (bool) delegates subscription requests;
  optional user_registration_enabled (bool) delegates registrations. Null leaves
  the provider default of false for each. Optional url is the external endpoint;
  optional validation_key is its base64 request-validation key.
- protocols (optional object): optional http2_enabled (bool) enables HTTP/2.
  Optional enable_http2 (bool) is its legacy fallback; current spelling wins.
  Null leaves the provider's false default.
- security (optional object): all fields are optional bools; null leaves provider
  transport defaults unchanged, and an explicit false is preserved.
  The provider defaults the six protocol flags and the named AES cipher flags
  below to false; these are not typed module defaults.
  backend_ssl30_enabled, backend_tls10_enabled, backend_tls11_enabled enable
  SSL 3.0, TLS 1.0, and TLS 1.1 on connections to backends, respectively.
  frontend_ssl30_enabled, frontend_tls10_enabled, frontend_tls11_enabled enable
  those protocols on incoming client connections, respectively.
  For each protocol field, the legacy enable_backend_ssl30/enable_backend_tls10/
  enable_backend_tls11 or enable_frontend_ssl30/enable_frontend_tls10/
  enable_frontend_tls11 spelling is the second choice. The corresponding
  disable_backend_ssl30/disable_backend_tls10/disable_backend_tls11 or
  disable_frontend_ssl30/disable_frontend_tls10/disable_frontend_tls11 spelling
  is the final legacy choice and is inverted: true disables the corresponding
  protocol, while false enables it. Prefer the current *_enabled spelling.
  The cipher flags below each enable the cipher named by the field:
  tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled (ECDHE/ECDSA AES-128-CBC-SHA),
  tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled (ECDHE/ECDSA AES-256-CBC-SHA),
  tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled (ECDHE/RSA AES-128-CBC-SHA),
  tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled (ECDHE/RSA AES-256-CBC-SHA),
  tls_rsa_with_aes128_cbc_sha256_ciphers_enabled (RSA AES-128-CBC-SHA256),
  tls_rsa_with_aes128_cbc_sha_ciphers_enabled (RSA AES-128-CBC-SHA),
  tls_rsa_with_aes128_gcm_sha256_ciphers_enabled (RSA AES-128-GCM-SHA256),
  tls_rsa_with_aes256_cbc_sha256_ciphers_enabled (RSA AES-256-CBC-SHA256),
  tls_rsa_with_aes256_cbc_sha_ciphers_enabled (RSA AES-256-CBC-SHA), and
  tls_rsa_with_aes256_gcm_sha384_ciphers_enabled (RSA AES-256-GCM-SHA384).
  Legacy tls_ecdheRsa_with_aes128_cbc_sha_ciphers_enabled and
  tls_ecdheRsa_with_aes256_cbc_sha_ciphers_enabled are lower-priority aliases
  for the two current ECDHE/RSA fields. triple_des_ciphers_enabled enables
  RSA/3DES-EDE-CBC-SHA; enable_triple_des_ciphers is its legacy fallback.
- sign_in (optional object): required enabled (bool) redirects anonymous portal
  users to sign-in.
- sign_up (optional object): required enabled (bool) allows portal registrations.
  Optional terms_of_service uses the terms structure below; it is conditionally
  required unless the legacy top-level terms_of_service object is supplied.
- terms_of_service (optional legacy object): fallback for sign_up.terms_of_service;
  nested terms take precedence. Both structures require consent_required (bool)
  to ask for consent and enabled (bool) to display terms; optional text supplies
  the terms users agree to.
- tenant_access (optional object): required enabled (bool) allows access to the
  management API using tenant access credentials.
- tags (optional string map, defaults to {}): resource tags; when base_tags is
  true, settings tags override resource-group tags, which override global tags.
- timeouts (optional object): create limits service provisioning, read retrieval,
  update configuration changes, and delete removal. Each optional duration-string
  field defaults to null, retaining its provider timeout.
Undeclared attributes are discarded by the settings object type.
DESCRIPTION
  type = object({
    name                = string
    publisher_name      = string
    publisher_email     = string
    sku_name            = string
    region              = optional(string)
    resource_group_key  = optional(string)
    resource_group_name = optional(string)
    resource_group = optional(object({
      key    = optional(string)
      lz_key = optional(string)
      name   = optional(string)
    }))

    additional_location = optional(object({
      location             = string
      capacity             = optional(number)
      zones                = optional(list(string))
      public_ip_address_id = optional(string)
      gateway_disabled     = optional(bool)
      virtual_network_configuration = optional(object({
        subnet_id  = optional(string)
        lz_key     = optional(string)
        vnet_key   = optional(string)
        subnet_key = optional(string)
      }))
    }))
    additional_locations = optional(map(object({
      location             = string
      capacity             = optional(number)
      zones                = optional(list(string))
      public_ip_address_id = optional(string)
      gateway_disabled     = optional(bool)
      virtual_network_configuration = optional(object({
        subnet_id  = optional(string)
        lz_key     = optional(string)
        vnet_key   = optional(string)
        subnet_key = optional(string)
      }))
    })), {})
    certificate = optional(object({
      encoded_certificate  = string
      store_name           = string
      certificate_password = optional(string)
    }))
    certificates = optional(map(object({
      encoded_certificate  = string
      store_name           = string
      certificate_password = optional(string)
    })), {})
    client_certificate_enabled = optional(bool)
    delegation = optional(object({
      subscriptions_enabled     = optional(bool)
      user_registration_enabled = optional(bool)
      url                       = optional(string)
      validation_key            = optional(string)
    }))
    gateway_disabled     = optional(bool)
    min_api_version      = optional(string)
    zones                = optional(list(string))
    public_ip_address_id = optional(string)
    public_ip_address = optional(object({
      key    = string
      lz_key = optional(string)
    }))
    public_network_access_enabled = optional(bool, true)
    virtual_network_type          = optional(string, "None")
    virtual_network_configuration = optional(object({
      subnet_id  = optional(string)
      lz_key     = optional(string)
      vnet_key   = optional(string)
      subnet_key = optional(string)
    }))
    identity = optional(object({
      type                  = string
      identity_ids          = optional(list(string))
      managed_identity_keys = optional(list(string), [])
      remote                = optional(map(object({ managed_identity_keys = list(string) })), {})
    }))
    hostname_configuration = optional(object({
      managements = optional(map(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      })), {})
      portals = optional(map(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      })), {})
      developer_portals = optional(map(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      })), {})
      proxies = optional(map(object({
        default_ssl_binding             = optional(bool)
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      })), {})
      scms = optional(map(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      })), {})
      management = optional(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      }))
      portal = optional(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      }))
      developer_portal = optional(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      }))
      proxy = optional(object({
        default_ssl_binding             = optional(bool)
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      }))
      scm = optional(object({
        host_name                       = string
        key_vault_certificate_id        = optional(string)
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool)
        ssl_keyvault_identity_client_id = optional(string)
      }))
    }))
    management = optional(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool)
      ssl_keyvault_identity_client_id = optional(string)
    }))
    portal = optional(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool)
      ssl_keyvault_identity_client_id = optional(string)
    }))
    developer_portal = optional(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool)
      ssl_keyvault_identity_client_id = optional(string)
    }))
    proxy = optional(object({
      default_ssl_binding             = optional(bool)
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool)
      ssl_keyvault_identity_client_id = optional(string)
    }))
    scm = optional(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      key_vault_id                    = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool)
      ssl_keyvault_identity_client_id = optional(string)
    }))
    notification_sender_email = optional(string)
    protocols = optional(object({
      http2_enabled = optional(bool)
      enable_http2  = optional(bool)
    }))
    security = optional(object({
      backend_ssl30_enabled                               = optional(bool)
      backend_tls10_enabled                               = optional(bool)
      backend_tls11_enabled                               = optional(bool)
      frontend_ssl30_enabled                              = optional(bool)
      frontend_tls10_enabled                              = optional(bool)
      frontend_tls11_enabled                              = optional(bool)
      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = optional(bool)
      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = optional(bool)
      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = optional(bool)
      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = optional(bool)
      tls_ecdheRsa_with_aes128_cbc_sha_ciphers_enabled    = optional(bool)
      tls_ecdheRsa_with_aes256_cbc_sha_ciphers_enabled    = optional(bool)
      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = optional(bool)
      tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = optional(bool)
      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = optional(bool)
      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = optional(bool)
      tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = optional(bool)
      tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = optional(bool)
      triple_des_ciphers_enabled                          = optional(bool)
      enable_backend_ssl30                                = optional(bool)
      enable_backend_tls10                                = optional(bool)
      enable_backend_tls11                                = optional(bool)
      enable_frontend_ssl30                               = optional(bool)
      enable_frontend_tls10                               = optional(bool)
      enable_frontend_tls11                               = optional(bool)
      enable_triple_des_ciphers                           = optional(bool)
      disable_backend_ssl30                               = optional(bool)
      disable_backend_tls10                               = optional(bool)
      disable_backend_tls11                               = optional(bool)
      disable_frontend_ssl30                              = optional(bool)
      disable_frontend_tls10                              = optional(bool)
      disable_frontend_tls11                              = optional(bool)
    }))
    sign_in = optional(object({
      enabled = bool
    }))
    sign_up = optional(object({
      enabled = bool
      terms_of_service = optional(object({
        consent_required = bool
        enabled          = bool
        text             = optional(string)
      }))
    }))
    terms_of_service = optional(object({
      consent_required = bool
      enabled          = bool
      text             = optional(string)
    }))
    tenant_access = optional(object({
      enabled = bool
    }))
    tags                = optional(map(string), {})
    diagnostic_profiles = optional(map(any), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = (
      var.settings.sign_up == null ||
      try(var.settings.sign_up.terms_of_service, null) != null ||
      var.settings.terms_of_service != null
    )
    error_message = "When sign_up is configured, provide sign_up.terms_of_service or the legacy top-level terms_of_service block."
  }

}

variable "remote_objects" {
  description = "Remote objects used to resolve API Management dependencies."
  type        = any
  default     = {}
}

variable "location" {
  description = "Location of the resource if different from the resource group."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Resource group name to deploy the Azure resource."
  type        = string
  default     = null
}

variable "resource_group" {
  description = "Resource group object to deploy the Azure resource."
  type        = any
}

variable "base_tags" {
  description = "Whether base tags should be inherited from the resource group."
  type        = bool
}

variable "public_ip_addresses" {
  description = "Public IP addresses used to resolve public IP references."
  type        = any
  default     = {}
}

variable "private_endpoints" {
  description = "Private endpoints for the API Management Gateway subresource. Private endpoints cannot be configured with Consumption_* SKUs."
  type        = any
  default     = {}
}

variable "private_dns" {
  description = "Combined private DNS zones used by private endpoint DNS zone groups."
  type        = any
  default     = {}
}

variable "resource_groups" {
  description = "Combined resource groups used to place private endpoints."
  type        = any
  default     = {}
}
