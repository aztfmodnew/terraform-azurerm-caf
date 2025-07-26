output "name" {
  value = azurerm_maps_account.map.name
}
output "id" {
  value = azurerm_maps_account.map.id
}
output "primary_access_key" {
  value = azurerm_maps_account.map.primary_access_key
}
output "secondary_access_key" {
  value = azurerm_maps_account.map.secondary_access_key
}
output "x_ms_client_id" {
  value = azurerm_maps_account.map.x_ms_client_id
}
output "tags" {
  value = azurerm_maps_account.map.tags

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
