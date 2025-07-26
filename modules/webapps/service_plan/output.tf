output "id" {
  value = azurerm_service_plan.sp.id
}

output "kind" {
  value = azurerm_service_plan.sp.kind
}

output "reserved" {
  value = azurerm_service_plan.sp.reserved
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
