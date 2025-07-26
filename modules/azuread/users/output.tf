

output "rbac_id" {
  value       = azuread_user.account.object_id
  description = "This attribute is used to set the role assignment"
}

output "id" {
  value = azuread_user.account.id
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
