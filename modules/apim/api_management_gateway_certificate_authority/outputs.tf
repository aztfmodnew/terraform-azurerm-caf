output "id" {
  description = "Gateway certificate authority association ARM ID."
  value       = azurerm_api_management_gateway_certificate_authority.resource.id
}
output "certificate_name" {
  description = "Resolved existing APIM certificate name."
  value       = azurerm_api_management_gateway_certificate_authority.resource.certificate_name
}
output "gateway_name" {
  description = "Resolved existing APIM gateway name."
  value       = azurerm_api_management_gateway_certificate_authority.resource.gateway_name
}
