output "id" {
  value = azurerm_key_vault_key.key.id
}

output "name" {
  value = var.settings.name
}

output "versionless_id" {
  value = azurerm_key_vault_key.key.versionless_id
}

output "public_key_pem" {
  value = azurerm_key_vault_key.key.public_key_pem
}

output "public_key_openssh" {
  value = azurerm_key_vault_key.key.public_key_openssh
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
