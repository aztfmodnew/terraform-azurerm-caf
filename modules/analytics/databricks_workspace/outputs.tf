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

output "disk_encryption_set_id" {
  description = "The ID of the managed disk encryption set created by the Databricks workspace."
  value       = azurerm_databricks_workspace.ws.disk_encryption_set_id
}

output "managed_disk_identity" {
  description = "The managed disk identity used by the Databricks workspace for customer-managed keys."
  value       = try(azurerm_databricks_workspace.ws.managed_disk_identity[0], null)
}

output "storage_account_identity" {
  description = "The storage account identity used by the Databricks workspace for customer-managed keys."
  value       = try(azurerm_databricks_workspace.ws.storage_account_identity[0], null)
}

output "root_dbfs_customer_managed_key_id" {
  description = "The ID of the optional root DBFS customer-managed key configuration."
  value       = try(azurerm_databricks_workspace_root_dbfs_customer_managed_key.root_dbfs["root_dbfs"].id, null)
}