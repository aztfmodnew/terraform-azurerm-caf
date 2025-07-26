output "id" {
  value       = azurerm_relay_namespace.rns.id
  description = "The Azure Relay Namespace ID."
}
output "primary_connection_string" {
  value       = azurerm_relay_namespace.rns.primary_connection_string
  description = "The primary connection string for the authorization rule `RootManageSharedAccessKey`."
}
output "secondary_connection_string" {
  value       = azurerm_relay_namespace.rns.secondary_connection_string
  description = "The secondary connection string for the authorization rule `RootManageSharedAccessKey`."
}
output "primary_key" {
  value       = azurerm_relay_namespace.rns.primary_key
  description = "The primary access key for the authorization rule `RootManageSharedAccessKey`."
}
output "secondary_key" {
  value       = azurerm_relay_namespace.rns.secondary_key
  description = "The secondary access key for the authorization rule `RootManageSharedAccessKey`."
}
output "metric_id" {
  value       = azurerm_relay_namespace.rns.metric_id
  description = "The Identifier for Azure Insights metrics."
}

# Hybrid naming outputs
output "name" {
  value       = local.final_name
  description = "The name of the resource"
}

output "naming_method" {
  value       = local.naming_method
  description = "The naming method used for this resource (passthrough, local_module, azurecaf, or fallback)"
}

output "naming_config" {
  value       = local.naming_config
  description = "Complete naming configuration metadata for debugging and governance"
}
