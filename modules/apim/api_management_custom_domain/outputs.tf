output "id" {
  value       = azurerm_api_management_custom_domain.apim.id
  description = "The ID of the API Management Custom Domain."
}
output "developer_portals" {
  value       = azurerm_api_management_custom_domain.apim.developer_portal
  description = "Developer portal endpoints and computed certificate metadata. Contains sensitive certificate material."
  sensitive   = true
}
output "managements" {
  value       = azurerm_api_management_custom_domain.apim.management
  description = "Management endpoints and computed certificate metadata. Contains sensitive certificate material."
  sensitive   = true
}
output "portals" {
  value       = azurerm_api_management_custom_domain.apim.portal
  description = "Legacy portal endpoints and computed certificate metadata. Contains sensitive certificate material."
  sensitive   = true
}
output "gateways" {
  value       = azurerm_api_management_custom_domain.apim.gateway
  description = "Gateway endpoints and computed certificate metadata. Contains sensitive certificate material."
  sensitive   = true
}
output "scms" {
  value       = azurerm_api_management_custom_domain.apim.scm
  description = "SCM endpoints and computed certificate metadata. Contains sensitive certificate material."
  sensitive   = true
}
