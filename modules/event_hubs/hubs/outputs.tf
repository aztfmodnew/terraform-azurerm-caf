output "id" {
  description = "The ID of the EventHub."
  value       = azurerm_eventhub.evhub.id
}

output "name" {
  description = "The name of the EventHub."
  value       = azurerm_eventhub.evhub.name
}

output "namespace_id" {
  description = "The ARM ID of the parent Event Hub Namespace."
  value       = azurerm_eventhub.evhub.namespace_id
}

output "partition_ids" {
  description = "The partition identifiers of the Event Hub."
  value       = azurerm_eventhub.evhub.partition_ids
}

output "status" {
  description = "The current Event Hub status."
  value       = azurerm_eventhub.evhub.status
}

output "authorization_rules" {
  description = "Authorization rules created within the Event Hub."
  value = {
    for key, rule in module.authorization_rules : key => {
      id   = rule.id
      name = rule.name
    }
  }
}