output "id" {
  description = "The ID of the Event Hub Namespace authorization rule."
  value       = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.id
}

output "primary_connection_string_alias" {
  description = "The sensitive primary connection string alias for the Event Hub Namespace authorization rule."
  value       = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.primary_connection_string_alias
  sensitive   = true
}

output "primary_connection_string" {
  description = "The sensitive primary connection string for the Event Hub Namespace authorization rule."
  value       = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.primary_connection_string
  sensitive   = true
}

output "primary_key" {
  description = "The sensitive primary SAS key for the Event Hub Namespace authorization rule."
  value       = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.primary_key
  sensitive   = true
}

output "secondary_connection_string_alias" {
  description = "The sensitive secondary connection string alias for the Event Hub Namespace authorization rule."
  value       = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.secondary_connection_string_alias
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The sensitive secondary connection string for the Event Hub Namespace authorization rule."
  value       = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.secondary_connection_string
  sensitive   = true
}

output "secondary_key" {
  description = "The sensitive secondary SAS key for the Event Hub Namespace authorization rule."
  value       = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.secondary_key
  sensitive   = true
}

output "name" {
  value       = azurerm_eventhub_namespace_authorization_rule.evh_ns_rule.name
  description = "Name of the authorization rule"
}

output "resource_group_name" {
  value       = var.resource_group_name
  description = "Name of the resource group"
}
