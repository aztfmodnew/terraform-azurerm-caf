output "id" {
  value       = azurerm_network_interface_backend_address_pool_association.nibapa.id
  description = "The (Terraform specific) ID of the Association between the Network Interface and the Load Balancers Backend Address Pool."
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
