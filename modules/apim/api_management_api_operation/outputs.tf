output "id" {
  value       = azurerm_api_management_api_operation.apim.id
  description = "The ID of the API Management API Operation."
}

output "operation_id" {
  value       = azurerm_api_management_api_operation.apim.operation_id
  description = "The API Management operation identifier within its API."
}
