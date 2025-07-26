output "id" {
  description = "The ID of the Databricks Workspace in the Azure management plane."
  value       = azurerm_databricks_workspace.ws.id

}

output "managed_resource_group_id" {
  description = "The ID of the Managed Resource Group created by the Databricks Workspace."
  value       = azurerm_databricks_workspace.ws.managed_resource_group_id

}

output "workspace_url" {
  description = "The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'"
  value       = azurerm_databricks_workspace.ws.workspace_url

}

output "workspace_id" {
  description = "The unique identifier of the databricks workspace in Databricks control plane."
  value       = azurerm_databricks_workspace.ws.workspace_id

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
