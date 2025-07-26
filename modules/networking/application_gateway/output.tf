output "id" {
  value = azurerm_application_gateway.agw.id

}

output "private_ip_address" {
  value = local.private_ip_address
}

output "backend_address_pools" {
  value = zipmap(azurerm_application_gateway.agw.backend_address_pool.*.name, azurerm_application_gateway.agw.backend_address_pool.*.id)
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
