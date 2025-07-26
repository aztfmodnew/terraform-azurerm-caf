output "id" {
  value = azurerm_virtual_desktop_host_pool.wvdpool.id
}

output "name" {
  value = azurerm_virtual_desktop_host_pool.wvdpool.name
}

output "token" {
  value     = azurerm_virtual_desktop_host_pool_registration_info.wvdpool.token
  sensitive = true
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
