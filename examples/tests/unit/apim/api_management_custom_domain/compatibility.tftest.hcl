mock_provider "azurerm" {
  mock_resource "azurerm_key_vault" {
    defaults = {
      id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.KeyVault/vaults/migrationtest"
      vault_uri = "https://migrationtest.vault.azure.net/"
    }
  }
}
mock_provider "azuread" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "migrationtest" }
  }
}

variables {
  global_settings = {
    prefixes       = []
    random_length  = 0
    passthrough    = true
    use_slug       = false
    environment    = "test"
    default_region = "region1"
    regions        = { region1 = "westeurope" }
  }
  client_config = {
    landingzone_key = "local"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    object_id       = "00000000-0000-0000-0000-000000000000"
  }
  location            = "westeurope"
  resource_group_name = "migrationtest"
  resource_group      = { name = "migrationtest", location = "westeurope", tags = {} }
  base_tags           = false
  remote_objects      = {}
  private_endpoints   = {}
  resource_groups     = {}
  vnets               = {}
  diagnostics         = { diagnostics_definition = {} }
}

run "apim_custom_domain_legacy_remote_certificate" {
  command = plan
  module {
    source = "../modules/apim/api_management_custom_domain"
  }
  variables {
    base_tags         = {}
    api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.ApiManagement/service/test"
    remote_objects = {
      keyvault_certificates = { local = { cert = { secret_id = "https://migrationtest.vault.azure.net/secrets/cert" } } }
    }
    settings = {
      gateways = [{ host_name = "api.example.com", key_vault_certificate = { certificate_key = "cert" } }]
    }
  }
  assert {
    condition     = one(azurerm_api_management_custom_domain.apim.gateway).key_vault_certificate_id == "https://migrationtest.vault.azure.net/secrets/cert"
    error_message = "Legacy same-landing-zone certificate lookup must resolve to its secret URI."
  }
}
