mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/test"
    }
  }
}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "queuetest" }
  }
}
mock_provider "azapi" {}

run "legacy_disabled_metrics_and_current_metrics" {
  command = plan
  module {
    source = "../modules/storage_account"
  }
  variables {
    global_settings = {
      prefixes      = []
      suffixes      = []
      random_length = 0
      passthrough   = false
      use_slug      = true
    }
    client_config   = { landingzone_key = "local" }
    resource_group  = { name = "test", location = "australiaeast" }
    base_tags       = false
    var_folder_path = "."
    storage_account = {
      name                     = "queuetest"
      account_tier             = "Standard"
      account_replication_type = "LRS"
      queues = {
        nested = { name = "nested" }
      }
      queue_properties = {
        minute_metrics = {
          enabled = false
          version = "1.0"
        }
        hour_metrics = {
          version      = "1.0"
          include_apis = true
        }
      }
    }
  }
  assert {
    condition     = try(length(azurerm_storage_account_queue_properties.stg["queue_properties"].minute_metrics), 0) == 0
    error_message = "Legacy disabled minute metrics must not emit an enabling block."
  }
  assert {
    condition     = azurerm_storage_account_queue_properties.stg["queue_properties"].hour_metrics[0].include_apis
    error_message = "Current metrics without an enabled flag must retain their settings."
  }
  assert {
    condition     = module.queue["nested"].name == "nested"
    error_message = "Nested queues must receive the storage account ID."
  }
}
