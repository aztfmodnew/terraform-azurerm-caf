mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "sasfixture" }
  }
}

run "legacy_sas_key_vault_block" {
  command = plan
  module {
    source = "../modules/data_factory/linked_services/azure_blob_storage"
  }
  variables {
    global_settings = { prefixes = [], random_length = 0, passthrough = false, use_slug = true }
    client_config   = { landingzone_key = "local" }
    data_factory_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.DataFactory/factories/test"
    settings = {
      name    = "legacy"
      sas_uri = "https://test.blob.core.windows.net"
      key_vault_sas_token = {
        linked_service_name = "vault"
        secret_name         = "legacy-secret"
      }
    }
  }
  assert {
    condition     = azurerm_data_factory_linked_service_azure_blob_storage.linked_service_azure_blob_storage.sas_token_linked_key_vault_key[0].secret_name == "legacy-secret"
    error_message = "The legacy Key Vault SAS block must map to the current provider block."
  }
}

run "current_sas_key_vault_block_precedence" {
  command = plan
  module {
    source = "../modules/data_factory/linked_services/azure_blob_storage"
  }
  variables {
    global_settings = { prefixes = [], random_length = 0, passthrough = false, use_slug = true }
    client_config   = { landingzone_key = "local" }
    data_factory_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.DataFactory/factories/test"
    settings = {
      name    = "current"
      sas_uri = "https://test.blob.core.windows.net"
      key_vault_sas_token = {
        linked_service_name = "vault"
        secret_name         = "legacy-secret"
      }
      sas_token_linked_key_vault_key = {
        linked_service_name = "vault"
        secret_name         = "current-secret"
      }
    }
  }
  assert {
    condition     = azurerm_data_factory_linked_service_azure_blob_storage.linked_service_azure_blob_storage.sas_token_linked_key_vault_key[0].secret_name == "current-secret"
    error_message = "The current Key Vault SAS block must take precedence over its legacy alias."
  }
}
