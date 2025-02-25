output "id" {
  value = azurerm_ai_services.ai_services.id
}

output "endpoint" {
  value = azurerm_ai_services.ai_services.endpoint
}

output "primary_access_key" {
  value = azurerm_ai_services.ai_services.primary_access_key
}

output "secondary_access_key" {
  value = azurerm_ai_services.ai_services.secondary_access_key
}

output "principal_id" {
  description = "The Principal ID associated with this Managed Service Identity."
  value       = azurerm_ai_services.ai_services.principal_id
}

output "tenant_id" {
  description = "The Tenant ID associated with this Managed Service Identity."
  value       = azurerm_ai_services.ai_services.tenant_id
}