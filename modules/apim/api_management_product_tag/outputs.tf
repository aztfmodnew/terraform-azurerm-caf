output "id" {
  description = "Product tag association ARM ID."
  value       = azurerm_api_management_product_tag.resource.id
}
output "name" {
  description = "Existing tag name, unchanged."
  value       = azurerm_api_management_product_tag.resource.name
}
output "api_management_product_id" {
  description = "Resolved short product identifier (not an ARM ID)."
  value       = azurerm_api_management_product_tag.resource.api_management_product_id
}
