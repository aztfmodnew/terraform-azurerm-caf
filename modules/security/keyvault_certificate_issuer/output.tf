output "id" {
  value = azurerm_key_vault_certificate_issuer.keycertisr.id
}

output "name" {
  value = azurerm_key_vault_certificate_issuer.keycertisr.name
}

# Hybrid naming outputs

output "naming_method" {
  value       = local.naming_method
  description = "The naming method used for this resource (passthrough, local_module, azurecaf, or fallback)"
}

output "naming_config" {
  value       = local.naming_config
  description = "Complete naming configuration metadata for debugging and governance"
}
