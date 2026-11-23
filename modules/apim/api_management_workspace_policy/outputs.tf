output "id" {
  description = "Workspace policy ARM ID."
  value       = azurerm_api_management_workspace_policy.resource.id
}
output "api_management_workspace_id" {
  description = "Resolved parent workspace ARM ID."
  value       = local.api_management_workspace_id
}
