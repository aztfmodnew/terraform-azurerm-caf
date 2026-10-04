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
