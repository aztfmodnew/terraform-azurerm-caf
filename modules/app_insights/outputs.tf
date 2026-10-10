output "id" {
  description = "The ID of the Application Insights component."
  value       = azurerm_application_insights.appinsights.id
}

output "app_id" {
  description = "The App ID associated with this Application Insights component."
  value       = azurerm_application_insights.appinsights.app_id
}

output "workspace_id" {
  description = "The Log Analytics workspace ID associated with this component."
  value       = azurerm_application_insights.appinsights.workspace_id
}

output "instrumentation_key" {
  description = "The Instrumentation Key for this Application Insights component."
  value       = azurerm_application_insights.appinsights.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "The Connection String for this Application Insights component. (Sensitive)"

  value     = azurerm_application_insights.appinsights.connection_string
  sensitive = true
}
