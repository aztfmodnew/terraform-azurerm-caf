output "id" {
  description = "The ID of the Fabric Capacity."
  value       = azurerm_fabric_capacity.fabric_capacity.id
}

output "name" {
  description = "The CAF-compliant name assigned to the Fabric Capacity."
  value       = azurecaf_name.fabric_capacity.result
}

output "location" {
  description = "The Azure region where the Fabric Capacity is deployed."
  value       = azurerm_fabric_capacity.fabric_capacity.location
}

output "sku" {
  description = "The SKU configuration applied to the Fabric Capacity."
  value       = azurerm_fabric_capacity.fabric_capacity.sku
}

output "administration_members" {
  description = "The list of administration members for the Fabric Capacity."
  value       = azurerm_fabric_capacity.fabric_capacity.administration_members
}

output "tags" {
  description = "The tags applied to the Fabric Capacity."
  value       = azurerm_fabric_capacity.fabric_capacity.tags
}
