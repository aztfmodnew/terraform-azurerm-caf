output "id" {
  value = azurerm_container_registry.acr.id

}

output "name" {
  value = azurecaf_name.acr.result
}

output "resource_group_name" {
  value       = local.resource_group_name
  description = "Resource group name is exported to allow the data source to retrieve the admin password if needed."
}

output "login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "login_server_url" {
  value = "https://${azurerm_container_registry.acr.login_server}"
}

output "admin_username" {
  value = azurerm_container_registry.acr.admin_username
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
