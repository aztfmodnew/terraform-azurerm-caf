output "id" {
  description = "Workspace certificate ARM ID."
  value       = azurerm_api_management_workspace_certificate.resource.id
}
output "name" {
  description = "CAF certificate name."
  value       = azurerm_api_management_workspace_certificate.resource.name
}
output "api_management_workspace_id" {
  description = "Resolved parent workspace ARM ID."
  value       = local.api_management_workspace_id
}
output "expiration" {
  description = "Certificate expiry date."
  value       = azurerm_api_management_workspace_certificate.resource.expiration
}
output "subject" {
  description = "Certificate subject."
  value       = azurerm_api_management_workspace_certificate.resource.subject
}
output "thumbprint" {
  description = "Certificate thumbprint."
  value       = azurerm_api_management_workspace_certificate.resource.thumbprint
}
