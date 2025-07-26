output "resource_guid" {
  value       = azurerm_nat_gateway.nat_gateway.resource_guid
  description = "The resource GUID property of the NAT Gateway."
}

output "id" {
  value       = azurerm_nat_gateway.nat_gateway.id
  description = "The ID of the NAT Gateway."
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
