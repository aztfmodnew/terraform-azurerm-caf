output "id" {
  description = "The ID of the AI Services Account"
  value       = azurerm_ai_services.ai_services.id
}

output "endpoint" {
  description = "The endpoint used to connect to the AI Services Account."
  value       = azurerm_ai_services.ai_services.endpoint
}

output "primary_access_key" {
  description = "The primary access key for the AI Services Account."
  value       = azurerm_ai_services.ai_services.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the AI Services Account."
  value       = azurerm_ai_services.ai_services.secondary_access_key
  sensitive   = true
}

output "principal_id" {
  description = "The Principal ID associated with this Managed Service Identity."
  value       = try(azurerm_ai_services.ai_services.identity[0].principal_id, null)
  sensitive   = false
}

output "tenant_id" {
  description = "The Tenant ID associated with this Managed Service Identity."
  value       = try(azurerm_ai_services.ai_services.identity[0].tenant_id, null)
  sensitive   = false
}
