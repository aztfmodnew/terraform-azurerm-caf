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

run "kusto_legacy_single_extension" {
  command = plan
  module {
    source = "../modules/databases/data_explorer/kusto_clusters"
  }
  variables {
    base_tags = {}
    settings = {
      name                = "migrationtest"
      sku                 = { name = "Dev(No SLA)_Standard_D11_v2", capacity = 1 }
      language_extensions = { name = "PYTHON", image = "Python3_11_7" }
    }
  }
  assert {
    condition     = one(azurerm_kusto_cluster.kusto.language_extension).name == "PYTHON"
    error_message = "The legacy single-object Kusto extension must remain accepted."
  }
}
run "kusto_current_extension_collection" {
  command = plan
  module {
    source = "../modules/databases/data_explorer/kusto_clusters"
  }
  variables {
    base_tags = {}
    settings = {
      name               = "migrationtest"
      sku                = { name = "Dev(No SLA)_Standard_D11_v2", capacity = 1 }
      language_extension = [{ name = "PYTHON", image = "Python3_11_7" }]
    }
  }
  assert {
    condition     = one(azurerm_kusto_cluster.kusto.language_extension).image == "Python3_11_7"
    error_message = "The current Kusto extension collection must be supported."
  }
}
