output "id" {
  value = azurerm_container_app.ca.id
}
output "custom_domain_verification_id" {
  value = azurerm_container_app.ca.custom_domain_verification_id
}
output "latest_revision_fqdn" {
  value = azurerm_container_app.ca.latest_revision_fqdn
}
output "latest_revision_name" {
  value = azurerm_container_app.ca.latest_revision_name
}
output "outbound_ip_addresses" {
  value = azurerm_container_app.ca.outbound_ip_addresses
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
