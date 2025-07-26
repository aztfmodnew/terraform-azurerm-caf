output "id" {
  value = azurerm_network_watcher.netwatcher.id
}
output "name" {
  value = azurerm_network_watcher.netwatcher.name
}
output "resource_group_name" {
  value = var.resource_group_name
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
