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

run "iot_legacy_recommendations_and_disabled_solution" {
  command = plan
  module {
    source = "../modules/iot/security/security_solution"
  }
  variables {
    iothub_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Devices/iotHubs/test"]
    settings = {
      name                    = "migrationtest"
      display_name            = "Migration test"
      enabled                 = false
      recommendations_enabled = { open_ports = false }
    }
  }
  assert {
    condition     = !azurerm_iot_security_solution.securitysolution.enabled && !azurerm_iot_security_solution.securitysolution.recommendations[0].open_ports
    error_message = "Legacy IoT recommendations and enabled=false must be preserved."
  }
}
