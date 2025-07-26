output "id" {
  description = "The ID of the Maintenance Configuration."
  value       = azurerm_maintenance_configuration.maintenance_configuration.id
}

output "maintenance_configuration_name" {
  description = "The name of the maintenance configuration."
  value       = azurerm_maintenance_configuration.maintenance_configuration.name
}

output "maintenance_configuration_location" {
  description = "The location where the resource exists"
  value       = azurerm_maintenance_configuration.maintenance_configuration.location
}
# Hybrid naming outputs
output "name_calculated" {
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
