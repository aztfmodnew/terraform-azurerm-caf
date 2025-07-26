output "id" {
  value = azurerm_private_dns_resolver.pvt_dns_resolver.id
}
output "tags" {
  value = azurerm_private_dns_resolver.pvt_dns_resolver.tags
}

output "location" {
  value = azurerm_private_dns_resolver.pvt_dns_resolver.location
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
