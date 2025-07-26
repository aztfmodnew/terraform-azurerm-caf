output "cosmos_account" {
  value = azurerm_cosmosdb_account.cosmos_account.id
}

output "primary_key" {
  value = azurerm_cosmosdb_account.cosmos_account.primary_key
}

output "endpoint" {
  value = azurerm_cosmosdb_account.cosmos_account.endpoint
}

output "name" {
  value = azurecaf_name.cdb.result
}

output "resource_group_name" {
  value = local.resource_group_name
}

output "location" {
  value = local.location
}

output "id" {
  value = azurerm_cosmosdb_account.cosmos_account.id
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
