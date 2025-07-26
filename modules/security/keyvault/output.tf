output "id" {
  value = azurerm_key_vault.keyvault.id
}

output "vault_uri" {
  value = azurerm_key_vault.keyvault.vault_uri
}


output "name" {
  value = azurerm_key_vault.keyvault.name
}

output "rbac_id" {
  value = azurerm_key_vault.keyvault.id
}

output "base_tags" {
  value = local.tags
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
