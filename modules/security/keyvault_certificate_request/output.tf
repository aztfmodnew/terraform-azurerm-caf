output "id" {
  value = azurerm_key_vault_certificate.csr.id
}
output "keyvault_id" {
  value = var.keyvault_id
}
output "keyvault_uri" {
  value = var.keyvault_uri
}
output "secret_id" {
  value = azurerm_key_vault_certificate.csr.secret_id
}
output "version" {
  value = azurerm_key_vault_certificate.csr.version
}
output "thumbprint" {
  value = azurerm_key_vault_certificate.csr.thumbprint
}
output "certificate_attribute" {
  value = azurerm_key_vault_certificate.csr.certificate_attribute
}
output "name" {
  value = azurerm_key_vault_certificate.csr.name
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
