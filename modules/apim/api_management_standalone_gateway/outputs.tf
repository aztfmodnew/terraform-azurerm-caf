output "id" {
  description = "Standalone gateway ARM resource ID."
  value       = azurerm_api_management_standalone_gateway.resource.id
}
output "name" {
  description = "CAF-generated standalone gateway name."
  value       = azurerm_api_management_standalone_gateway.resource.name
}
output "location" {
  description = "Resolved gateway Azure region."
  value       = azurerm_api_management_standalone_gateway.resource.location
}
output "resource_group_name" {
  description = "Resolved gateway resource group name."
  value       = azurerm_api_management_standalone_gateway.resource.resource_group_name
}
