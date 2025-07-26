output "id" {
  value = azurerm_iothub_dps.iothubdps.id
}

output "name" {
  value = azurerm_iothub_dps.iothubdps.name
}

output "device_provisioning_host_name" {
  value = azurerm_iothub_dps.iothubdps.device_provisioning_host_name
}

output "id_scope" {
  value = azurerm_iothub_dps.iothubdps.id_scope
}

output "service_operations_host_name" {
  value = azurerm_iothub_dps.iothubdps.service_operations_host_name
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
