output "id" {
  description = "API schema ARM resource ID."
  value       = azurerm_api_management_api_schema.resource.id
}
output "schema_id" {
  description = "CAF-generated schema identifier within the API."
  value       = azurerm_api_management_api_schema.resource.schema_id
}
output "api_name" {
  description = "Resolved parent API name."
  value       = azurerm_api_management_api_schema.resource.api_name
}
