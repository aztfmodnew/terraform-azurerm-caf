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

run "nsg_flow_log_uses_target_resource_id" {
  command = plan
  module {
    source = "../modules/networking/virtual_network/nsg/flow_logs"
  }
  variables {
    client_config     = { landingzone_key = "local" }
    resource_location = "westeurope"
    resource_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/networkSecurityGroups/test"
    network_watchers  = {}
    diagnostics = {
      diagnostics_destinations = {
        storage = {
          all_regions = {
            westeurope = { storage_account_key = "logs" }
          }
        }
      }
      storage_accounts = {
        logs = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Storage/storageAccounts/logs" }
      }
    }
    settings = {
      name            = "migrationtest-flow"
      storage_account = { storage_account_destination = "all_regions" }
    }
  }
  assert {
    condition     = azurerm_network_watcher_flow_log.flow[0].target_resource_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/networkSecurityGroups/test"
    error_message = "The flow log's target_resource_id must receive the selected network security group ID."
  }
}
