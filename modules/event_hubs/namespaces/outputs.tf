output "id" {
  description = "The EventHub Namespace ID."
  value       = azurerm_eventhub_namespace.evh.id
}

output "name" {
  description = "The EventHub Namespace name."
  value       = azurerm_eventhub_namespace.evh.name
}

output "resource_group_name" {
  value       = local.resource_group_name
  description = "Name of the resource group"
}

output "location" {
  value       = local.location
  description = "Location of the service"
}

output "tags" {
  value       = azurerm_eventhub_namespace.evh.tags
  description = "A mapping of tags to assign to the resource."
}

output "rbac_id" {
  description = "The identity principal ID used by CAF role assignments."
  value       = try(azurerm_eventhub_namespace.evh.identity[0].principal_id, null)
}

output "principal_id" {
  description = "The principal ID of the Event Hub Namespace managed identity."
  value       = try(azurerm_eventhub_namespace.evh.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "The tenant ID of the Event Hub Namespace managed identity."
  value       = try(azurerm_eventhub_namespace.evh.identity[0].tenant_id, null)
}

output "event_hubs" {
  description = "Event Hubs created within the namespace."
  value       = module.event_hubs
}

output "event_hub_namespace_auth_rules" {
  description = "Authorization rules created within the namespace."
  value = {
    for key, rule in module.event_hub_namespace_auth_rules : key => {
      id   = rule.id
      name = rule.name
    }
  }
}