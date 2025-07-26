output "id" {
  value       = azurerm_app_configuration.config.id
  description = "The ID of the App Config."
}

output "endpoint" {
  value       = azurerm_app_configuration.config.endpoint
  description = "The URL of the App Configuration."
}

output "identity" {
  value       = try(azurerm_app_configuration.config.identity, null)
  description = "The managed service identity object."
}

output "rbac_id" {
  value       = try(azurerm_app_configuration.config.identity[0].principal_id, null)
  description = "The rbac_id of the App Config for role assignments."
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
