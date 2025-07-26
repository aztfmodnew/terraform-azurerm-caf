output "id" {
  value = azurerm_user_assigned_identity.msi.id
}

output "principal_id" {
  value = azurerm_user_assigned_identity.msi.principal_id
}

output "client_id" {
  value = azurerm_user_assigned_identity.msi.client_id
}

output "rbac_id" {
  value       = azurerm_user_assigned_identity.msi.principal_id
  description = "This attribute is used to set the role assignment"
}

output "name" {
  value = azurerm_user_assigned_identity.msi.name
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
