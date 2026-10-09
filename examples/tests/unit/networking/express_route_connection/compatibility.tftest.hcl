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

run "express_route_connection_legacy_internet_security_alias" {
  command = plan
  module {
    source = "../modules/networking/express_route_connection"
  }
  variables {
    client_config                    = { landingzone_key = "local" }
    express_route_gateway_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/expressRouteGateways/gateway"
    express_route_circuit_peering_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/expressRouteCircuits/circuit/peerings/AzurePrivatePeering"
    virtual_hub_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/virtualHubs/hub"
    settings = {
      name                     = "migrationtest"
      enable_internet_security = true
    }
  }
  assert {
    condition     = azurerm_express_route_connection.erc.internet_security_enabled
    error_message = "The legacy enable_internet_security setting must map to internet_security_enabled."
  }
}
run "express_route_connection_current_flag_precedence" {
  command = plan
  module {
    source = "../modules/networking/express_route_connection"
  }
  variables {
    client_config                    = { landingzone_key = "local" }
    express_route_gateway_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/expressRouteGateways/gateway"
    express_route_circuit_peering_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/expressRouteCircuits/circuit/peerings/AzurePrivatePeering"
    virtual_hub_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/virtualHubs/hub"
    settings = {
      name                      = "migrationtest"
      internet_security_enabled = true
      enable_internet_security  = false
    }
  }

  assert {
    condition     = azurerm_express_route_connection.erc.internet_security_enabled
    error_message = "The current internet_security_enabled setting must take precedence over its legacy alias."
  }
}
