mock_provider "azurerm" {
  mock_data "azurerm_eventhub_namespace" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.EventHub/namespaces/legacy"
    }
  }
}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "migrationtest" }
  }
}

variables {
  global_settings    = { prefixes = [], random_length = 0, passthrough = false, use_slug = true }
  client_config      = { landingzone_key = "local" }
  storage_account_id = null
  settings           = { name = "migrationtest", partition_count = 2, message_retention = 1 }
}

run "legacy_namespace_name_lookup" {
  command = plan
  module {
    source = "../modules/event_hubs/hubs"
  }
  variables {
    namespace_name      = "legacy"
    resource_group_name = "test"
  }
  assert {
    condition     = length(data.azurerm_eventhub_namespace.evh) == 1 && azurerm_eventhub.evhub.namespace_id == data.azurerm_eventhub_namespace.evh[0].id
    error_message = "Legacy namespace names must resolve to a namespace ARM ID."
  }
}
run "direct_id_skips_namespace_lookup" {
  command = plan
  module {
    source = "../modules/event_hubs/hubs"
  }
  variables {
    namespace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.EventHub/namespaces/direct"
  }
  assert {
    condition     = length(data.azurerm_eventhub_namespace.evh) == 0 && azurerm_eventhub.evhub.namespace_id == var.namespace_id
    error_message = "A direct namespace ARM ID must not require a data lookup."
  }
}
run "namespace_reference_takes_precedence" {
  command = plan
  module {
    source = "../modules/event_hubs/hubs"
  }
  variables {
    namespace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.EventHub/namespaces/direct"
    namespace    = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.EventHub/namespaces/current" }
  }
  assert {
    condition     = length(data.azurerm_eventhub_namespace.evh) == 0 && azurerm_eventhub.evhub.namespace_id == var.namespace.id
    error_message = "The structured namespace reference must take precedence without a data lookup."
  }
}

run "retention_and_keyless_capture_settings" {
  command = plan
  module {
    source = "../modules/event_hubs/hubs"
  }
  variables {
    namespace_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.EventHub/namespaces/current"
    storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/capture"
    settings = {
      name            = "migrationtest"
      partition_count = 2
      retention_description = {
        cleanup_policy          = "Delete"
        retention_time_in_hours = 48
      }
      capture_description = {
        enabled  = true
        encoding = "Avro"
        destination = {
          name                        = "EventHubArchive.AzureBlockBlob"
          archive_name_format         = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
          blob_container_name         = "capture"
          storage_authentication_type = "UserAssigned"
          storage_authentication_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/capture"
        }
      }
      timeouts = {
        create = "45m"
        update = "45m"
      }
    }
  }
  assert {
    condition = (
      azurerm_eventhub.evhub.retention_description[0].cleanup_policy == "Delete" &&
      azurerm_eventhub.evhub.retention_description[0].retention_time_in_hours == 48 &&
      azurerm_eventhub.evhub.capture_description[0].destination[0].storage_authentication_type == "UserAssigned" &&
      azurerm_eventhub.evhub.capture_description[0].destination[0].storage_authentication_id != null
    )
    error_message = "Retention and identity-based capture settings must reach the Event Hub resource."
  }
}
