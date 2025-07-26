output "id" {
  value = azurerm_express_route_circuit_authorization.circuitauth.id

  description = "Express Route Circuit Authorization ID"
}
output "authorization_key" {
  value       = azurerm_express_route_circuit_authorization.circuitauth.authorization_key
  sensitive   = true
  description = "The authorization key"
}
output "authorization_use_status" {
  value = azurerm_express_route_circuit_authorization.circuitauth.authorization_use_status

  description = "The authorization use status."
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
