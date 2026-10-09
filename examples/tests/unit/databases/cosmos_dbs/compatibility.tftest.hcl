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

run "cosmos_legacy_disabled_inverts_to_enabled" {
  command = plan
  module {
    source = "../modules/databases/cosmos_dbs"
  }
  variables {
    settings = {
      name                          = "migrationtest"
      offer_type                    = "Standard"
      local_authentication_disabled = true
      consistency_policy            = { consistency_level = "Session" }
      geo_locations                 = { primary = { location = "westeurope", failover_priority = 0 } }
    }
  }
  assert {
    condition     = !azurerm_cosmosdb_account.cosmos_account.local_authentication_enabled
    error_message = "Legacy disabled=true must map to enabled=false."
  }
}
run "cosmos_current_false_takes_precedence" {
  command = plan
  module {
    source = "../modules/databases/cosmos_dbs"
  }
  variables {
    settings = {
      name                          = "migrationtest"
      offer_type                    = "Standard"
      local_authentication_enabled  = false
      local_authentication_disabled = false
      consistency_policy            = { consistency_level = "Session" }
      geo_locations                 = { primary = { location = "westeurope", failover_priority = 0 } }
    }
  }
  assert {
    condition     = !azurerm_cosmosdb_account.cosmos_account.local_authentication_enabled
    error_message = "Current enabled=false must take precedence over legacy disabled=false."
  }
}
