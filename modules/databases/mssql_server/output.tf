output "id" {
  value = azurerm_mssql_server.mssql.id
}

output "fully_qualified_domain_name" {
  value = azurerm_mssql_server.mssql.fully_qualified_domain_name
}

output "rbac_id" {
  value = try(azurerm_mssql_server.mssql.identity[0].principal_id, null)
}

output "identity" {
  value = try(azurerm_mssql_server.mssql.identity, null)
}

output "azuread_administrator" {
  value = try(azurerm_mssql_server.mssql.azuread_administrator, null)
}

output "name" {
  value = azurecaf_name.mssql.result
}

output "resource_group_name" {
  value = local.resource_group_name
}

output "location" {
  value = local.location
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
