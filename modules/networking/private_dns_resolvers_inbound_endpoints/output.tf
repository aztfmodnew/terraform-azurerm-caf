output "id" {
  value = azurerm_private_dns_resolver_inbound_endpoint.pvt_dns_resolver_inbound_endpoint.id
}

output "private_ip_address" {
  value = azurerm_private_dns_resolver_inbound_endpoint.pvt_dns_resolver_inbound_endpoint.ip_configurations[0].private_ip_address
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
