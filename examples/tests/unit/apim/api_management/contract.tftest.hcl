mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "migrationtest" }
  }
}

run "apim_inline_hostname_legacy_certificate_alias" {
  command = plan
  module {
    source = "../modules/apim/api_management"
  }
  variables {
    base_tags           = false
    client_config       = { landingzone_key = "local" }
    global_settings     = { prefixes = [], random_length = 0, passthrough = true, use_slug = false, tags = {} }
    location            = "westeurope"
    resource_group      = { name = "migrationtest", location = "westeurope", tags = {} }
    resource_group_name = "migrationtest"
    remote_objects      = {}
    public_ip_addresses = {}
    vnets               = {}
    settings = {
      name            = "migrationtest"
      publisher_name  = "Migration test"
      publisher_email = "owner@example.com"
      sku_name        = "Developer_1"
      protocols = {
        enable_http2 = true
      }
      security = {
        enable_backend_tls10                             = true
        disable_backend_ssl30                            = true
        tls_ecdheRsa_with_aes128_cbc_sha_ciphers_enabled = true
        tls_rsa_with_aes256_gcm_sha384_ciphers_enabled   = true
      }
      portal = {
        host_name = "portal.example.com"
      }
      hostname_configuration = {
        proxy = {
          host_name    = "api.example.com"
          key_vault_id = "https://migrationtest.vault.azure.net/secrets/legacy"
        }
      }
    }
  }
  assert {
    condition     = one(azurerm_api_management.apim.hostname_configuration).proxy[0].key_vault_certificate_id == "https://migrationtest.vault.azure.net/secrets/legacy"
    error_message = "The legacy inline key_vault_id input must map to key_vault_certificate_id."
  }
  assert {
    condition     = one(azurerm_api_management.apim.protocols).http2_enabled
    error_message = "The legacy enable_http2 alias must map to http2_enabled."
  }
  assert {
    condition     = one(azurerm_api_management.apim.security).backend_tls10_enabled
    error_message = "The legacy enable_backend_tls10 alias must map to backend_tls10_enabled."
  }
  assert {
    condition     = one(azurerm_api_management.apim.security).backend_ssl30_enabled
    error_message = "The documented legacy disable_backend_ssl30 alias must preserve its historical inverted behavior."
  }
  assert {
    condition     = one(azurerm_api_management.apim.security).tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled
    error_message = "The documented legacy ECDHE-RSA cipher spelling must map to the provider argument."
  }
  assert {
    condition     = one(azurerm_api_management.apim.security).tls_rsa_with_aes256_gcm_sha384_ciphers_enabled
    error_message = "The TLS RSA AES-256 GCM cipher argument must be passed through."
  }
  assert {
    condition     = one(azurerm_api_management.apim.hostname_configuration).portal[0].host_name == "portal.example.com"
    error_message = "Legacy top-level hostname settings must remain supported."
  }
}

run "apim_inline_hostname_current_certificate_id_precedence" {
  command = plan
  module {
    source = "../modules/apim/api_management"
  }
  variables {
    base_tags           = false
    client_config       = { landingzone_key = "local" }
    global_settings     = { prefixes = [], random_length = 0, passthrough = true, use_slug = false, tags = {} }
    location            = "westeurope"
    resource_group      = { name = "migrationtest", location = "westeurope", tags = {} }
    resource_group_name = "migrationtest"
    remote_objects      = {}
    public_ip_addresses = {}
    vnets               = {}
    settings = {
      name            = "migrationtest"
      publisher_name  = "Migration test"
      publisher_email = "owner@example.com"
      sku_name        = "Developer_1"
      protocols = {
        http2_enabled = false
        enable_http2  = true
      }
      security = {
        backend_tls10_enabled = false
        enable_backend_tls10  = true
        disable_backend_tls10 = true
      }
      hostname_configuration = {
        proxy = {
          host_name                = "api.example.com"
          key_vault_certificate_id = "https://migrationtest.vault.azure.net/secrets/current"
          key_vault_id             = "https://migrationtest.vault.azure.net/secrets/legacy"
        }
      }
    }
  }
  assert {
    condition     = one(azurerm_api_management.apim.hostname_configuration).proxy[0].key_vault_certificate_id == "https://migrationtest.vault.azure.net/secrets/current"
    error_message = "The current inline certificate ID must take precedence over the legacy alias."
  }
  assert {
    condition     = one(azurerm_api_management.apim.protocols).http2_enabled == false
    error_message = "The current http2_enabled argument must take precedence over its legacy alias."
  }
  assert {
    condition     = one(azurerm_api_management.apim.security).backend_tls10_enabled == false
    error_message = "The current backend_tls10_enabled argument must take precedence over its legacy alias."
  }
}

run "apim_provider_options_and_repeated_blocks" {
  command = plan
  module {
    source = "../modules/apim/api_management"
  }
  variables {
    base_tags           = false
    client_config       = { landingzone_key = "local" }
    global_settings     = { prefixes = [], random_length = 0, passthrough = true, use_slug = false, tags = {} }
    location            = "westeurope"
    resource_group      = { name = "migrationtest", location = "westeurope", tags = {} }
    resource_group_name = "migrationtest"
    remote_objects      = {}
    public_ip_addresses = {}
    vnets               = {}
    settings = {
      name                          = "migrationtest"
      publisher_name                = "Migration test"
      publisher_email               = "owner@example.com"
      sku_name                      = "Developer_1"
      public_ip_address_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/publicIPAddresses/apim"
      public_network_access_enabled = false
      virtual_network_type          = "Internal"
      virtual_network_configuration = {
        subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/apim"
      }
      additional_location = {
        location = "eastus"
        capacity = 2
        virtual_network_configuration = {
          subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/apim-eastus"
        }
      }

      additional_locations = {
        westus = {
          location             = "westus"
          capacity             = 1
          zones                = ["1"]
          gateway_disabled     = true
          public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Network/publicIPAddresses/apim-westus"
        }
      }
      certificate = {
        encoded_certificate = "Y2VydA=="
        store_name          = "Root"
      }
      certificates = {
        authority = {
          encoded_certificate = "Y2VydA=="
          store_name          = "CertificateAuthority"
        }
      }
      delegation = {
        subscriptions_enabled     = true
        user_registration_enabled = true
        url                       = "https://example.com/delegation"
        validation_key            = "dGVzdA=="
      }
      hostname_configuration = {
        proxy = {
          host_name                       = "api.example.com"
          certificate                     = "Y2VydA=="
          certificate_password            = "test"
          ssl_keyvault_identity_client_id = "00000000-0000-0000-0000-000000000000"
        }
      }
      sign_up = {
        enabled = true
        terms_of_service = {
          consent_required = true
          enabled          = true
          text             = "Terms"
        }
      }
      timeouts = {
        create = "4h"
        read   = "10m"
        update = "4h"
        delete = "4h"
      }
    }
  }
  assert {
    condition     = azurerm_api_management.apim.public_network_access_enabled == false
    error_message = "public_network_access_enabled must be passed through to the API Management resource."
  }
  assert {
    condition     = length(azurerm_api_management.apim.additional_location) == 2
    error_message = "The legacy single location and the additional_locations map must both produce regional blocks."
  }
  assert {
    condition     = length(azurerm_api_management.apim.certificate) == 2
    error_message = "The legacy single certificate and certificates map must both produce certificate blocks."
  }
  assert {
    condition     = one(azurerm_api_management.apim.delegation).url == "https://example.com/delegation"
    error_message = "Delegation options must be passed through to the API Management resource."
  }
  assert {
    condition     = one(azurerm_api_management.apim.hostname_configuration).proxy[0].ssl_keyvault_identity_client_id == "00000000-0000-0000-0000-000000000000"
    error_message = "The proxy hostname Key Vault identity client ID must be passed through."
  }
  assert {
    condition     = one(azurerm_api_management.apim.sign_up).terms_of_service[0].consent_required
    error_message = "Terms of service must be read from the sign_up block."
  }
}
