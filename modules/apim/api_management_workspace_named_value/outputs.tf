output "id" {
  description = "Workspace named value ARM ID."
  value       = azurerm_api_management_workspace_named_value.resource.id
}
output "name" {
  description = "CAF named value resource name."
  value       = azurerm_api_management_workspace_named_value.resource.name
}
output "api_management_workspace_id" {
  description = "Resolved parent workspace ARM ID."
  value       = local.api_management_workspace_id
}
output "display_name" {
  description = "Unmodified identifier used in policy expressions."
  value       = azurerm_api_management_workspace_named_value.resource.display_name
}
output "secret" {
  description = "Whether Azure treats the value as secret."
  value       = azurerm_api_management_workspace_named_value.resource.secret
}
