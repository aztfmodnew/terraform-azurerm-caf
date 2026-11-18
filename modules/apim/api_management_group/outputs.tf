output "id" {
  value       = azurerm_api_management_group.apim.id
  description = "The ID of the API Management Group."
}
output "name" {
  value       = azurerm_api_management_group.apim.name
  description = "The CAF-generated group name."
}