output "id" {
  description = "Named value ARM resource ID."
  value       = azurerm_api_management_named_value.named_value.id
}

output "name" {
  description = "CAF-generated resource name."
  value       = azurerm_api_management_named_value.named_value.name
}

output "display_name" {
  description = "Stable name to use in APIM policy expressions."
  value       = azurerm_api_management_named_value.named_value.display_name
}
