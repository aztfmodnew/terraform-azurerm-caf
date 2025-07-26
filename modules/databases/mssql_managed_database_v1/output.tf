
output "name" {
  value       = azurerm_mssql_managed_database.sqlmanageddatabase.name
  description = "SQL Managed DB Name"
}

output "id" {
  value       = azurerm_mssql_managed_database.sqlmanageddatabase.id
  description = "SQL Managed DB Id"
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
