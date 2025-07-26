output "id" {
  value       = azurerm_data_factory_integration_runtime_azure_ssis.dfiras.id
  description = "The ID of the Data Factory Azure-SSIS Integration Runtime."
}
output "name" {
  value       = azurecaf_name.dfiras.result
  description = "The name of the Data Factory Azure-SSIS Integration Runtime."
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
