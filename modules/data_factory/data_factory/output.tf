output "id" {
  value = azurerm_data_factory.df.id
}

output "name" {
  value = azurerm_data_factory.df.name
}

output "identity" {
  value = try(azurerm_data_factory.df.identity, null)
}

output "rbac_id" {
  value = try(azurerm_data_factory.df.identity[0].principal_id, null)
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
