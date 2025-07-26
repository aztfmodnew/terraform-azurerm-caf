output "id" {
  value       = azurerm_logic_app_trigger_http_request.laachr.id
  description = "The ID of the HTTP Request Trigger within the Logic App Workflow"
}
# output "callback_url" {
#   value       = azurerm_logic_app_trigger_http_request.laachr.callback_url
#   description = "The URL for the workflow trigger"
# }

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
