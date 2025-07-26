output "id" {
  value       = azurerm_api_management_subscription.apim.id
  description = "The ID of the API Management subscription."
}

output "primary_key" {
  value       = azurerm_api_management_subscription.apim.primary_key
  description = "The primary subscription key to use for the subscription."
  sensitive   = true
}

output "secondary_key" {
  value       = azurerm_api_management_subscription.apim.secondary_key
  description = "The secondary subscription key to use for the subscription."
  sensitive   = true
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
