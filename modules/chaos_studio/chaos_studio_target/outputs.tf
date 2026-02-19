output "id" {
  description = "The ID of the Chaos Studio Target"
  value       = azurerm_chaos_studio_target.target.id
}

output "location" {
  description = "The Azure region of the Chaos Studio Target"
  value       = azurerm_chaos_studio_target.target.location
}

output "target_resource_id" {
  description = "The target resource ID of the Chaos Studio Target"
  value       = azurerm_chaos_studio_target.target.target_resource_id
}

output "target_type" {
  description = "The target type of the Chaos Studio Target"
  value       = azurerm_chaos_studio_target.target.target_type
}
