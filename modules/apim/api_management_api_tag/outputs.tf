output "id" {
  description = "API tag association ARM ID, suitable for api_tag_description.api_tag_id."
  value       = azurerm_api_management_api_tag.resource.id
}
output "name" {
  description = "Existing tag name, unchanged."
  value       = azurerm_api_management_api_tag.resource.name
}
output "api_id" {
  description = "Parent API ARM ID."
  value       = azurerm_api_management_api_tag.resource.api_id
}
