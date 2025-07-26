output "id" {
  description = "The ID of the Application Insights component."
  value       = azurerm_application_insights.appinsights.id
}

output "app_id" {
  description = "The App ID associated with this Application Insights component."
  value       = azurerm_application_insights.appinsights.app_id
}

output "instrumentation_key" {
  description = "The Instrumentation Key for this Application Insights component."
  value       = azurerm_application_insights.appinsights.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "The Connection String for this Application Insights component. (Sensitive)"

  value = azurerm_application_insights.appinsights.connection_string
}

# Hybrid naming outputs
output "name" {
  value       = local.final_name
  description = "The name of the resource"
}

output "naming_method" {
  value       = local.naming_method
  description = "The naming method used for this resource (passthrough, local_module, azurecaf, or fallback)"
}

output "naming_config" {
  value       = local.naming_config
  description = "Complete naming configuration metadata for debugging and governance"
}
