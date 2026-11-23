output "id" {
  description = "Product group association ARM ID."
  value       = azurerm_api_management_product_group.resource.id
}
output "product_id" {
  description = "Resolved short product identifier."
  value       = azurerm_api_management_product_group.resource.product_id
}
output "group_name" {
  description = "Resolved existing APIM group name."
  value       = azurerm_api_management_product_group.resource.group_name
}
