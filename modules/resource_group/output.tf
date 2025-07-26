output "location" {
  value = azurerm_resource_group.rg.location
}

output "tags" {
  value = azurerm_resource_group.rg.tags

}

output "rbac_id" {
  value = azurerm_resource_group.rg.id
}

output "id" {
  value = azurerm_resource_group.rg.id
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
