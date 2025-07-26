output "id" {
  value = azurerm_express_route_circuit_peering.peering.id
}

output "azure_asn" {
  value = azurerm_express_route_circuit_peering.peering.azure_asn
}

output "primary_azure_port" {
  value = azurerm_express_route_circuit_peering.peering.primary_azure_port
}

output "secondary_azure_port" {
  value = azurerm_express_route_circuit_peering.peering.secondary_azure_port
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
