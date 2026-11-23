output "id" {
  description = "Service-level APIM tag ARM ID."
  value       = azurerm_api_management_tag.resource.id
}
output "name" {
  description = "CAF-generated tag name to use in API/product associations."
  value       = azurerm_api_management_tag.resource.name
}
output "display_name" {
  description = "Tag display name returned by AzureRM."
  value       = azurerm_api_management_tag.resource.display_name
}
