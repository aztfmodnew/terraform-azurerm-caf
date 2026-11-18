output "id" {
  description = "Workspace API version set ARM ID."
  value       = azurerm_api_management_workspace_api_version_set.resource.id
}
output "name" {
  description = "CAF version set name."
  value       = azurerm_api_management_workspace_api_version_set.resource.name
}
output "api_management_workspace_id" {
  description = "Resolved parent workspace ARM ID."
  value       = local.api_management_workspace_id
}
output "versioning_scheme" {
  description = "API version selection scheme."
  value       = azurerm_api_management_workspace_api_version_set.resource.versioning_scheme
}
