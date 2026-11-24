output "id" {
  description = "The ID of the Event Hub authorization rule."
  value       = azurerm_eventhub_authorization_rule.evhub_rule.id
}

output "primary_connection_string_alias" {
  description = "The sensitive primary connection string alias for the Event Hub authorization rule."
  value       = azurerm_eventhub_authorization_rule.evhub_rule.primary_connection_string_alias
  sensitive   = true
}

output "secondary_connection_string_alias" {
  description = "The sensitive secondary connection string alias for the Event Hub authorization rule."
  value       = azurerm_eventhub_authorization_rule.evhub_rule.secondary_connection_string_alias
  sensitive   = true
}

output "primary_connection_string" {
  description = "The sensitive primary connection string for the Event Hub authorization rule."
  value       = azurerm_eventhub_authorization_rule.evhub_rule.primary_connection_string
  sensitive   = true
}

output "primary_key" {
  description = "The sensitive primary SAS key for the Event Hub authorization rule."
  value       = azurerm_eventhub_authorization_rule.evhub_rule.primary_key
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The sensitive secondary connection string for the Event Hub authorization rule."
  value       = azurerm_eventhub_authorization_rule.evhub_rule.secondary_connection_string
  sensitive   = true
}

output "secondary_key" {
  description = "The sensitive secondary SAS key for the Event Hub authorization rule."
  value       = azurerm_eventhub_authorization_rule.evhub_rule.secondary_key
  sensitive   = true
}

output "name" {
  description = "The name of the Event Hub authorization rule."
  value       = azurerm_eventhub_authorization_rule.evhub_rule.name
}