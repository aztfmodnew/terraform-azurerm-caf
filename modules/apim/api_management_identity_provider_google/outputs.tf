output "id" {
  description = "Google identity provider ARM ID."
  value       = azurerm_api_management_identity_provider_google.resource.id
}
output "api_management_name" {
  description = "Resolved parent APIM name."
  value       = local.api_management_name
}
output "resource_group_name" {
  description = "Resolved parent resource group name."
  value       = local.resource_group_name
}
output "client_id" {
  description = "Google application identifier, not its secret."
  value       = azurerm_api_management_identity_provider_google.resource.client_id
}
