output "id" {
  description = "Gateway hostname configuration ARM ID."
  value       = azurerm_api_management_gateway_host_name_configuration.resource.id
}
output "name" {
  description = "CAF-generated hostname configuration name."
  value       = azurerm_api_management_gateway_host_name_configuration.resource.name
}
output "host_name" {
  description = "Configured DNS host name."
  value       = azurerm_api_management_gateway_host_name_configuration.resource.host_name
}
output "gateway_name" {
  description = "Resolved parent gateway name."
  value       = azurerm_api_management_gateway_host_name_configuration.resource.gateway_name
}
