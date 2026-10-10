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

run "legacy_system_queue_endpoint" {
  command = plan
  module {
    source = "../modules/messaging/eventgrid/eventgrid_system_event_subscription"
  }
  variables {
    settings = {
      name                          = "delivery"
      resource_group                = { name = "test" }
      eventgrid_system_topic        = { key = "storage" }
      service_bus_queue_endpoint_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.ServiceBus/namespaces/ns/queues/queue"
    }
  }
  assert {
    condition     = azurerm_eventgrid_system_topic_event_subscription.eges.service_bus_queue_id == var.settings.service_bus_queue_endpoint_id
    error_message = "Legacy Service Bus queue endpoint must be retained."
  }
}
run "current_system_topic_endpoint_precedence" {
  command = plan
  module {
    source = "../modules/messaging/eventgrid/eventgrid_system_event_subscription"
  }
  variables {
    settings = {
      name                          = "delivery"
      resource_group                = { name = "test" }
      eventgrid_system_topic        = { key = "storage" }
      service_bus_topic_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.ServiceBus/namespaces/ns/topics/current"
      service_bus_topic_endpoint_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.ServiceBus/namespaces/ns/topics/legacy"
    }
  }
  assert {
    condition     = azurerm_eventgrid_system_topic_event_subscription.eges.service_bus_topic_id == var.settings.service_bus_topic_id
    error_message = "The current Service Bus topic endpoint must take precedence."
  }
}
