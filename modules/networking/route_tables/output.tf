output "id" {
  value = azurerm_route_table.rt.id

}

output "name" {
  value = azurerm_route_table.rt.name

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
