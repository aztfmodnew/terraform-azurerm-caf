output "id" {
  description = "The ID of Database Migration Service."
  value       = azurerm_database_migration_service.dms.id
}

output "name" {
  description = "The name of Database Migration Service."
  value       = azurerm_database_migration_service.dms.name
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
