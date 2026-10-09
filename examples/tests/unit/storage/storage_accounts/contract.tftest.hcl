mock_provider "azurerm" {
  source = "./tests/mock_data"
  mock_resource "azurerm_storage_account" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/test"
    }
  }
}
mock_provider "azurerm" {
  alias  = "vhub"
  source = "./tests/mock_data"
}
mock_provider "azuread" {
  source = "./tests/mock_data"
}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "migrationtest" }
  }
}
mock_provider "azapi" {
  mock_data "azapi_resource" {
    defaults = {
      output = { properties = { vaultUri = "https://legacy.vault.usgovcloudapi.net/" } }
    }
  }
}

run "storage_cmk_legacy_and_current_inputs" {
  command = plan
  module {
    source = "../"
  }
  variables {
    current_landingzone_key = "local"
    global_settings = {
      default_region = "region1"
      regions        = { region1 = "westeurope" }
      random_length  = 0
    }
    resource_groups = { test = { name = "test" } }
    remote_objects = {
      keyvaults = {
        remote = {
          known = {
            id        = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test/providers/Microsoft.KeyVault/vaults/known"
            vault_uri = "https://known.vault.azure.net/"
          }
          arm_only = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/test/providers/Microsoft.KeyVault/vaults/legacy"
          }
        }
      }
      keyvault_keys = {
        remote = {
          cmk = {
            name           = "encryption"
            id             = "https://known.vault.azure.net/keys/encryption/current-version"
            versionless_id = "https://known.vault.azure.net/keys/encryption"
          }
          old_state = {
            name = "encryption"
            id   = "https://known.vault.azure.net/keys/encryption/current-version"
          }
        }
      }
    }
    storage_accounts = {
      for key, cmk in {
        omitted       = { lz_key = "remote", keyvault_key_key = "cmk" }
        null_version  = { lz_key = "remote", keyvault_key_key = "cmk", key_version = null }
        empty_version = { lz_key = "remote", keyvault_key_key = "cmk", key_version = "" }
        pinned        = { lz_key = "remote", keyvault_key_key = "cmk", key_version = "chosen-version" }
        old_state     = { lz_key = "remote", keyvault_key_key = "old_state" }
        named         = { lz_key = "remote", keyvault_key = "known", key_name = "different-key", keyvault_key_key = "cmk", key_version = "chosen-version" }
        arm_only      = { lz_key = "remote", keyvault_key = "arm_only", key_name = "encryption" }
        direct        = { key_vault_key_id = "https://direct.vault.azure.net/keys/encryption/pinned", keyvault_key = "missing", key_name = "ignored", key_version = "ignored" }
        no_cmk        = null
        } : key => {
        name                     = key
        resource_group_key       = "test"
        account_tier             = "Standard"
        account_replication_type = "LRS"
        identity                 = { type = "SystemAssigned" }
        customer_managed_key     = cmk
      }
    }
  }
  assert {
    condition = alltrue([
      for key in ["omitted", "null_version", "empty_version", "old_state"] :
      azurerm_storage_account_customer_managed_key.cmk[key].key_vault_key_id == "https://known.vault.azure.net/keys/encryption"
    ])
    error_message = "Legacy key references must remain versionless when key_version is omitted, null or empty, including older remote outputs."
  }
  assert {
    condition     = azurerm_storage_account_customer_managed_key.cmk["pinned"].key_vault_key_id == "https://known.vault.azure.net/keys/encryption/chosen-version"
    error_message = "Explicit legacy key versions must remain pinned."
  }
  assert {
    condition     = azurerm_storage_account_customer_managed_key.cmk["named"].key_vault_key_id == "https://known.vault.azure.net/keys/different-key/chosen-version"
    error_message = "An explicit legacy key name must take precedence over the referenced key."
  }
  assert {
    condition     = azurerm_storage_account_customer_managed_key.cmk["arm_only"].key_vault_key_id == "https://legacy.vault.usgovcloudapi.net/keys/encryption" && length(data.azapi_resource.storage_account_cmk_vault) == 1
    error_message = "ARM-only vault references must resolve their actual cloud endpoint without unnecessary lookups."
  }
  assert {
    condition     = azurerm_storage_account_customer_managed_key.cmk["direct"].key_vault_key_id == "https://direct.vault.azure.net/keys/encryption/pinned"
    error_message = "The current direct key URI must take precedence over legacy settings."
  }
  assert {
    condition     = length(azurerm_storage_account_customer_managed_key.cmk) == 8
    error_message = "Null customer_managed_key must not create a CMK resource."
  }
}
