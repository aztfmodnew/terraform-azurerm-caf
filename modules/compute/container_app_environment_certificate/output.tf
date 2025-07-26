output "id" {
  value = azurerm_container_app_environment_certificate.caec.id
}
output "expiration_date" {
  value = azurerm_container_app_environment_certificate.caec.expiration_date
}
output "issue_date" {
  value = azurerm_container_app_environment_certificate.caec.issue_date
}
output "issuer" {
  value = azurerm_container_app_environment_certificate.caec.issuer
}
output "subject_name" {
  value = azurerm_container_app_environment_certificate.caec.subject_name
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
