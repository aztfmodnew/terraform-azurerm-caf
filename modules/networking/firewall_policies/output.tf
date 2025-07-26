
output "id" {
  description = "The ID of the Azure Firewall Polict"
  value       = azurerm_firewall_policy.fwpol.id
}

output "name" {
  description = "Name of the firewall policy"
  value       = azurerm_firewall_policy.fwpol.name
}

output "resource_group_name" {
  value = local.resource_group_name
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
