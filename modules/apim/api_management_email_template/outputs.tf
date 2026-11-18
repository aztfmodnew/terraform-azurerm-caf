output "id" {
  description = "Email template ARM ID."
  value       = azurerm_api_management_email_template.resource.id
}
output "template_name" {
  description = "Azure predefined template identifier."
  value       = azurerm_api_management_email_template.resource.template_name
}
output "title" {
  description = "Azure-computed template title."
  value       = azurerm_api_management_email_template.resource.title
}
output "description" {
  description = "Azure-computed template description."
  value       = azurerm_api_management_email_template.resource.description
}
output "api_management_name" {
  description = "Resolved parent APIM name."
  value       = local.api_management_name
}
output "resource_group_name" {
  description = "Resolved parent resource group name."
  value       = local.resource_group_name
}
