output "id" {
  description = "Group user membership ARM ID."
  value       = azurerm_api_management_group_user.resource.id
}
output "user_id" {
  description = "Resolved logical APIM user identifier (not an ARM ID)."
  value       = azurerm_api_management_group_user.resource.user_id
}
output "group_name" {
  description = "Resolved existing APIM group name."
  value       = azurerm_api_management_group_user.resource.group_name
}
