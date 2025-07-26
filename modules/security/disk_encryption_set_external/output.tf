output "principal_id" {
  value = azurerm_disk_encryption_set.encryption_set.identity.0.principal_id
}
output "tenant_id" {
  value = azurerm_disk_encryption_set.encryption_set.identity.0.tenant_id
}

output "id" {
  value = azurerm_disk_encryption_set.encryption_set.id
}

output "rbac_id" {
  value = azurerm_disk_encryption_set.encryption_set.identity.0.principal_id
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
