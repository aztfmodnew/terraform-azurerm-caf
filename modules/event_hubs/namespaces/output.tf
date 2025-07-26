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

output "event_hubs" {
  value = module.event_hubs
}
# Hybrid naming outputs

output "naming_method" {
  value       = local.naming_method
  description = "The naming method used for this resource (passthrough, local_module, azurecaf, or fallback)"
}

output "naming_config" {
  value       = local.naming_config
  description = "Complete naming configuration metadata for debugging and governance"
}
