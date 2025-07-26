output "id" {
  value = azurerm_postgresql_server.postgresql.id
}

output "fqdn" {
  value = azurerm_postgresql_server.postgresql.fqdn
}

output "rbac_id" {
  value = try(azurerm_postgresql_server.postgresql.identity[0].principal_id, null)
}

output "identity" {
  value = try(azurerm_postgresql_server.postgresql.identity, null)
}

output "name" {
  value = azurecaf_name.postgresql.result
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
