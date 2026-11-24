output "id" {
  description = "The ID of the EventHub Consumer Group."
  value       = azurerm_eventhub_consumer_group.evhcg.id
}

output "name" {
  description = "The name of the Event Hub Consumer Group."
  value       = azurerm_eventhub_consumer_group.evhcg.name
}

output "eventhub_name" {
  description = "The name of the parent Event Hub."
  value       = azurerm_eventhub_consumer_group.evhcg.eventhub_name
}

output "namespace_name" {
  description = "The name of the parent Event Hub Namespace."
  value       = azurerm_eventhub_consumer_group.evhcg.namespace_name
}