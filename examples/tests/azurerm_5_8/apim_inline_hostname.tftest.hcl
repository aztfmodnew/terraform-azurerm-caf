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
}
