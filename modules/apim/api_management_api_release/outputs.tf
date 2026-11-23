output "id" {
  description = "API release ARM resource ID."
  value       = azurerm_api_management_api_release.resource.id
}
output "name" {
  description = "CAF-generated release name."
  value       = azurerm_api_management_api_release.resource.name
}
output "api_id" {
  description = "Released API revision ARM ID."
  value       = azurerm_api_management_api_release.resource.api_id
}
