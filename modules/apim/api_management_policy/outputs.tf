output "id" {
  description = "Service policy ARM resource ID."
  value       = azurerm_api_management_policy.resource.id
}
output "api_management_id" {
  description = "Parent APIM service ARM ID."
  value       = azurerm_api_management_policy.resource.api_management_id
}
