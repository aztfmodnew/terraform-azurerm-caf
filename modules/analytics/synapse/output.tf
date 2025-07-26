output "id" {
  description = "The ID of the Synapse Workspace."
  value       = azurerm_synapse_workspace.ws.id
}

output "connectivity_endpoints" {
  description = "A list of Connectivity endpoints for this Synapse Workspace."
  value       = azurerm_synapse_workspace.ws.connectivity_endpoints

}

output "managed_resource_group_name" {
  description = "Workspace managed resource group."
  value       = azurerm_synapse_workspace.ws.managed_resource_group_name
}

output "identity" {
  description = "An identity block which contains the Managed Service Identity information for this Synapse Workspace. - type - The Identity Type for the Service Principal associated with the Managed Service Identity of this Synapse Workspace. principal_id - The Principal ID for the Service Principal associated with the Managed Service Identity of this Synapse Workspace. tenant_id - The Tenant ID for the Service Principal associated with the Managed Service Identity of this Synapse Workspace."
  value       = azurerm_synapse_workspace.ws.identity

}

output "spark_pool" {
  description = "Spark pool object"
  value       = module.spark_pool
}

output "sql_pool" {
  description = "SQL pool object"
  value       = module.sql_pool
}

output "rbac_id" {
  value = azurerm_synapse_workspace.ws.identity[0].principal_id

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
