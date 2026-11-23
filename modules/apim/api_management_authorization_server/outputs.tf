output "id" {
  description = "Authorization server ARM ID."
  value       = azurerm_api_management_authorization_server.resource.id
}
output "name" {
  description = "CAF authorization server name."
  value       = azurerm_api_management_authorization_server.resource.name
}
output "api_management_name" {
  description = "Resolved parent APIM name."
  value       = local.api_management_name
}
output "resource_group_name" {
  description = "Resolved parent resource group name."
  value       = local.resource_group_name
}
output "display_name" {
  description = "Authorization server display name."
  value       = azurerm_api_management_authorization_server.resource.display_name
}
