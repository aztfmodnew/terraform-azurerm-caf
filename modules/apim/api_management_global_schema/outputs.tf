output "id" {
  description = "Global schema ARM resource ID."
  value       = azurerm_api_management_global_schema.resource.id
}
output "schema_id" {
  description = "CAF-generated schema identifier within APIM."
  value       = azurerm_api_management_global_schema.resource.schema_id
}
output "type" {
  description = "Schema content type."
  value       = azurerm_api_management_global_schema.resource.type
}
