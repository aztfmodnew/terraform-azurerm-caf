output "id" {
  value       = azurerm_communication_service.acs.id
  description = "The ID of the Communication Service."
}
output "primary_connection_string" {
  value       = azurerm_communication_service.acs.primary_connection_string
  description = "The primary connection string of the Communication Service."
}
output "secondary_connection_string" {
  value       = azurerm_communication_service.acs.secondary_connection_string
  description = "The secondary connection string of the Communication Service."
}
output "primary_key" {
  value       = azurerm_communication_service.acs.primary_key
  description = "The primary key of the Communication Service."
}
output "secondary_key" {
  value       = azurerm_communication_service.acs.secondary_key
  description = "The secondary key of the Communication Service."
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
