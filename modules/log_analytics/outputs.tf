output "id" {
  value = azurerm_log_analytics_workspace.law.id

}

output "location" {
  value = azurerm_log_analytics_workspace.law.location

}

output "name" {
  value = azurerm_log_analytics_workspace.law.name

}

output "resource_group_name" {
  value = azurerm_log_analytics_workspace.law.resource_group_name

}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.law.workspace_id
}

output "primary_shared_key" {
  value     = azurerm_log_analytics_workspace.law.primary_shared_key
  sensitive = true
}

output "secondary_shared_key" {
  value       = azurerm_log_analytics_workspace.law.secondary_shared_key
  description = "The secondary shared key for authenticating to the workspace."
  sensitive   = true
}

output "identity" {
  value       = azurerm_log_analytics_workspace.law.identity
  description = "The managed identity assigned to the workspace."
}

output "principal_id" {
  value       = try(azurerm_log_analytics_workspace.law.identity[0].principal_id, null)
  description = "The system-assigned managed identity principal ID, when present."
}

output "tenant_id" {
  value       = try(azurerm_log_analytics_workspace.law.identity[0].tenant_id, null)
  description = "The managed identity tenant ID, when present."
}

output "solutions" {
  value = {
    for key, solution in azurerm_log_analytics_solution.solution : key => {
      id = solution.id
    }
  }
  description = "Log Analytics solutions keyed by their configured solution name."
}
