output "id" {
  description = "Version set ARM ID, suitable for API version_set_id."
  value       = azurerm_api_management_api_version_set.resource.id
}
output "name" {
  description = "CAF-generated version set name."
  value       = azurerm_api_management_api_version_set.resource.name
}
output "display_name" {
  description = "Version set display name."
  value       = azurerm_api_management_api_version_set.resource.display_name
}
