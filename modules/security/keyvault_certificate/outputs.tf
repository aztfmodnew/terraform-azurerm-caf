output "id" {
  description = "The Key Vault Certificate ID."
  value       = azurerm_key_vault_certificate.cert.id
}

output "secret_id" {
  description = "The ID of the associated Key Vault Secret."
  value       = azurerm_key_vault_certificate.cert.secret_id
}

output "version" {
  description = "The current version of the Key Vault Certificate."
  value       = azurerm_key_vault_certificate.cert.version
}

output "versionless_id" {
  description = "The Base ID of the Key Vault Certificate."
  value       = azurerm_key_vault_certificate.cert.versionless_id
}

output "versionless_secret_id" {
  description = "The Base ID of the Key Vault Secret."
  value       = azurerm_key_vault_certificate.cert.versionless_secret_id
}

output "certificate_data" {
  description = "The raw Key Vault Certificate data represented as a hexadecimal string."
  value       = azurerm_key_vault_certificate.cert.certificate_data
}

output "certificate_data_base64" {
  description = "The Base64 encoded Key Vault Certificate data."
  value       = azurerm_key_vault_certificate.cert.certificate_data_base64
}

output "thumbprint" {
  description = "The X509 Thumbprint of the Key Vault Certificate represented as a hexadecimal string."
  value       = azurerm_key_vault_certificate.cert.thumbprint
}

output "certificate_attribute" {
  description = "A certificate_attribute block as defined below."
  value       = azurerm_key_vault_certificate.cert.certificate_attribute
}

output "resource_manager_id" {
  description = "The (Versioned) ID for this Key Vault Certificate. This property points to a specific version of a Key Vault Certificate, as such using this won't auto-rotate values if used in other Azure Services."
  value       = azurerm_key_vault_certificate.cert.resource_manager_id
}

output "resource_manager_versionless_id" {
  description = "The Versionless ID of the Key Vault Certificate. This property allows other Azure Services (that support it) to auto-rotate their value when the Key Vault Certificate is updated."
  value       = azurerm_key_vault_certificate.cert.resource_manager_versionless_id
}