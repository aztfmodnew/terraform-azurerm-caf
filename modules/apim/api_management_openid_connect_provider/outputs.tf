output "id" {
  description = "OpenID Connect provider ARM ID."
  value       = azurerm_api_management_openid_connect_provider.resource.id
}
output "name" {
  description = "CAF provider name."
  value       = azurerm_api_management_openid_connect_provider.resource.name
}
output "api_management_name" {
  description = "Resolved parent APIM name."
  value       = local.api_management_name
}
output "resource_group_name" {
  description = "Resolved parent resource group name."
  value       = local.resource_group_name
}
output "metadata_endpoint" {
  description = "OpenID discovery metadata URI."
  value       = azurerm_api_management_openid_connect_provider.resource.metadata_endpoint
}
