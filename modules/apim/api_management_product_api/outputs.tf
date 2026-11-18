output "id" {
  description = "Product API association ARM ID."
  value       = azurerm_api_management_product_api.resource.id
}
output "product_id" {
  description = "Resolved short product identifier."
  value       = azurerm_api_management_product_api.resource.product_id
}
output "api_name" {
  description = "Resolved existing API name."
  value       = azurerm_api_management_product_api.resource.api_name
}
