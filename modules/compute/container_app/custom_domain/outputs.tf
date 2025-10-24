output "id" {
  value       = azurerm_container_app_custom_domain.custom_domain.id
  description = "The ID of the Container App Custom Domain"
}

output "name" {
  value       = azurerm_container_app_custom_domain.custom_domain.name
  description = "The name of the Container App Custom Domain"
}

output "container_app_environment_managed_certificate_id" {
  value       = azurerm_container_app_custom_domain.custom_domain.container_app_environment_managed_certificate_id
  description = "The ID of the Container App Environment Managed Certificate"
}
