output "id" {
  description = "API tag description ARM resource ID."
  value       = azurerm_api_management_api_tag_description.resource.id
}
output "api_tag_id" {
  description = "Parent API tag association ARM ID."
  value       = azurerm_api_management_api_tag_description.resource.api_tag_id
}
