output "id" {
  description = "The ID of the Chaos Studio Capability"
  value       = azurerm_chaos_studio_capability.capability.id
}

output "urn" {
  description = "The Unique Resource Name of the Capability"
  value       = azurerm_chaos_studio_capability.capability.urn
}

output "capability_type" {
  description = "The capability type of the Chaos Studio Capability"
  value       = azurerm_chaos_studio_capability.capability.capability_type
}

output "chaos_studio_target_id" {
  description = "The Chaos Studio Target ID"
  value       = azurerm_chaos_studio_capability.capability.chaos_studio_target_id
}
