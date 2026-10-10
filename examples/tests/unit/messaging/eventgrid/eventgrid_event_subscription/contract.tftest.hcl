mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "delivery" }
  }
}

variables {
  global_settings = {
    prefixes      = []
    random_length = 0
    passthrough   = true
    use_slug      = false
  }
  client_config = { landingzone_key = "local" }
  remote_objects = {
    eventgrid_system_topics = { local = { storage = { name = "storage" } } }
  }
}

run "legacy_eventhub_endpoint" {
  command = plan
  module {
    source = "../modules/messaging/eventgrid/eventgrid_event_subscription"
  }
  variables {
    settings = {
      name                 = "delivery"
      scope                = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test" }
      eventhub_endpoint_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.EventHub/namespaces/ns/eventhubs/hub"
    }
  }
  assert {
    condition     = azurerm_eventgrid_event_subscription.eges.eventhub_id == var.settings.eventhub_endpoint_id
    error_message = "Legacy Event Hub endpoint must map to eventhub_id."
  }
}
run "current_relay_endpoint_precedence" {
  command = plan
  module {
    source = "../modules/messaging/eventgrid/eventgrid_event_subscription"
  }
  variables {
    settings = {
      name                          = "delivery"
      scope                         = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test" }
      hybrid_connection_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Relay/namespaces/ns/hybridConnections/current"
      hybrid_connection_endpoint_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Relay/namespaces/ns/hybridConnections/legacy"
    }
  }
  assert {
    condition     = azurerm_eventgrid_event_subscription.eges.hybrid_connection_id == var.settings.hybrid_connection_id
    error_message = "The current Relay endpoint must take precedence."
  }
}
