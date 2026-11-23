output "id" {
  description = "AAD B2C identity provider ARM ID."
  value       = azurerm_api_management_identity_provider_aadb2c.resource.id
}
output "api_management_name" {
  description = "Resolved parent APIM name."
  value       = local.api_management_name
}
output "resource_group_name" {
  description = "Resolved parent resource group name."
  value       = local.resource_group_name
}
output "allowed_tenant" {
  description = "Allowed B2C tenant domain."
  value       = azurerm_api_management_identity_provider_aadb2c.resource.allowed_tenant
}
