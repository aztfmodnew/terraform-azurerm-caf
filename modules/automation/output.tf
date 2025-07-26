output "id" {
  description = "The Automation Account ID."
  value       = azurerm_automation_account.auto_account.id
}

output "dsc_server_endpoint" {
  description = "The DSC Server Endpoint associated with this Automation Account."
  value       = azurerm_automation_account.auto_account.dsc_server_endpoint
}

output "rbac_id" {
  description = "The rbac_id of the automation account for role assignments."
  value       = try(azurerm_automation_account.auto_account.identity[0].principal_id, null)
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
