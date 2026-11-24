output "id" {
  description = "The Cognitive Account Project ID."
  value       = azurerm_cognitive_account_project.project.id
}

output "name" {
  description = "The Cognitive Account Project name."
  value       = azurerm_cognitive_account_project.project.name
}

output "default" {
  description = "Whether this is the account's default project."
  value       = azurerm_cognitive_account_project.project.default
}

output "endpoints" {
  description = "Project endpoint URLs keyed by endpoint name."
  value       = azurerm_cognitive_account_project.project.endpoints
}

output "principal_id" {
  description = "Managed identity principal ID."
  value       = try(azurerm_cognitive_account_project.project.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "Managed identity tenant ID."
  value       = try(azurerm_cognitive_account_project.project.identity[0].tenant_id, null)
}

output "rbac_id" {
  description = "Managed identity principal ID for CAF role mappings."
  value       = try(azurerm_cognitive_account_project.project.identity[0].principal_id, null)
}
