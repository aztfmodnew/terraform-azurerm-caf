output "id" {
  description = "Policy fragment ARM resource ID."
  value       = azurerm_api_management_policy_fragment.resource.id
}
output "name" {
  description = "CAF-generated name to use in include-fragment policies."
  value       = azurerm_api_management_policy_fragment.resource.name
}
output "format" {
  description = "Policy fragment value format."
  value       = azurerm_api_management_policy_fragment.resource.format
}
