output "id" {
  value = azurerm_log_analytics_workspace.law.id

}

output "location" {
  value = azurerm_log_analytics_workspace.law.location

}

output "resource_group_name" {
  value = azurerm_log_analytics_workspace.law.resource_group_name

}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.law.workspace_id
}

output "primary_shared_key" {
  value = azurerm_log_analytics_workspace.law.primary_shared_key
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
