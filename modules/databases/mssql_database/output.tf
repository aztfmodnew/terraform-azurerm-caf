output "id" {
  value = azurerm_mssql_database.mssqldb.id
}

output "name" {
  value = azurerm_mssql_database.mssqldb.name
}

output "server_id" {
  value = azurerm_mssql_database.mssqldb.server_id
}

output "server_name" {
  value = var.server_name
}

output "server_fqdn" {
  value = local.server_name
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
