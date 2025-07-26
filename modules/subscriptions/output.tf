output "id" {
  value = format("/subscriptions/%s", try(azurerm_subscription.sub.0.subscription_id, var.settings.subscription_id, var.client_config.subscription_id))
}
output "subscription_id" {
  value = try(azurerm_subscription.sub.0.subscription_id, var.settings.subscription_id, var.client_config.subscription_id)
}

output "tenant_id" {
  value = try(azurerm_subscription.sub.0.tenant_id, var.client_config.tenant_id)
}

output "tags" {
  value = try(var.settings.tags, null)
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
