output "id" {
  description = "AAD identity provider ARM ID."
  value       = azurerm_api_management_identity_provider_aad.resource.id
}
output "api_management_name" {
  description = "Resolved parent APIM name."
  value       = local.api_management_name
}
output "resource_group_name" {
  description = "Resolved parent resource group name."
  value       = local.resource_group_name
}
output "allowed_tenants" {
  description = "Allowed Entra tenant identifiers."
  value       = azurerm_api_management_identity_provider_aad.resource.allowed_tenants
}
