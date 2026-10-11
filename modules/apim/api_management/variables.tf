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
API Management service settings.

Required: name, publisher_name, publisher_email, and sku_name. sku_name combines
a supported tier (Consumption, Developer, Basic, BasicV2, Standard, StandardV2,
Premium, or PremiumV2) and capacity, separated by an underscore.

Optional CAF inputs: region, resource_group_key, resource_group_name, and
resource_group. Optional provider settings: additional_location or
additional_locations, certificate or certificates, client_certificate_enabled,
delegation, gateway_disabled, min_api_version, zones, public_ip_address_id or
public_ip_address, public_network_access_enabled, virtual_network_type,
virtual_network_configuration, identity, hostname_configuration, management,
portal, developer_portal, proxy, scm, notification_sender_email, protocols,
security, sign_in, sign_up, terms_of_service, tenant_access, tags, and timeouts.
virtual_network_type accepts None, External, or Internal. Each regional location
can set capacity, zones, a public IP address, gateway_disabled, and its own
virtual_network_configuration. Hostname blocks support Key Vault certificate
IDs, inline certificates, client-certificate negotiation, and a Key Vault
identity client ID. Sign-up requires terms_of_service, either nested in
sign_up or supplied through the legacy top-level setting.

Legacy aliases remain supported for HTTP/2, security settings, hostname
certificate IDs, and the singular additional_location/certificate blocks.
When current and legacy hostname certificate IDs are both set, the current
key_vault_certificate_id takes precedence. public_network_access_enabled
defaults to true; Azure requires it to be true when the service is created.
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
    tags = optional(map(string), {})
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
