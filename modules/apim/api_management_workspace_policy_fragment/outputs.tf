output "id" {
  description = "Workspace policy fragment ARM ID."
  value       = azurerm_api_management_workspace_policy_fragment.resource.id
}
output "name" {
  description = "CAF policy fragment name."
  value       = azurerm_api_management_workspace_policy_fragment.resource.name
}
output "api_management_workspace_id" {
  description = "Resolved parent workspace ARM ID."
  value       = local.api_management_workspace_id
}
output "xml_format" {
  description = "Policy fragment XML format."
  value       = azurerm_api_management_workspace_policy_fragment.resource.xml_format
}
