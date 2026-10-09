output "id" {
  description = "The ID of the Machine Learning Workspace."
  value       = azurerm_machine_learning_workspace.ws.id
}

output "name" {
  description = "Name of the Machine Learning Workspace."
  value       = azurerm_machine_learning_workspace.ws.name
}

output "identity" {
  description = "The managed identity block exported by the Machine Learning Workspace."
  value       = azurerm_machine_learning_workspace.ws.identity
}

output "rbac_id" {
  description = "The system-assigned identity principal ID, when present."
  value       = try(azurerm_machine_learning_workspace.ws.identity[0].principal_id, null)
}

output "workspace_id" {
  description = "The immutable ID associated with the Machine Learning Workspace."
  value       = azurerm_machine_learning_workspace.ws.workspace_id
}

output "discovery_url" {
  description = "The discovery service URL for the Machine Learning Workspace."
  value       = azurerm_machine_learning_workspace.ws.discovery_url
}