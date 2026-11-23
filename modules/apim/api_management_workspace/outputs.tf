output "id" {
  description = "Workspace ARM ID."
  value       = azurerm_api_management_workspace.resource.id
}
output "name" {
  description = "CAF workspace name."
  value       = azurerm_api_management_workspace.resource.name
}
output "api_management_id" {
  description = "Resolved parent APIM ARM ID."
  value       = local.api_management_id
}
output "display_name" {
  description = "Workspace display name."
  value       = azurerm_api_management_workspace.resource.display_name
}
