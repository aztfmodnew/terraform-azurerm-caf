output "id" {
  value = azurerm_container_group.acg.id
}

output "ip_address" {
  value = azurerm_container_group.acg.ip_address
}

output "fqdn" {
  value = azurerm_container_group.acg.fqdn
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
