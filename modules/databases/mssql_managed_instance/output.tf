
output "name" {
  value       = azurecaf_name.mssqlmi.result
  description = "SQL MI Name"
}

output "id" {
  value       = local.output.id
  description = "SQL MI Id"
}

output "location" {
  value = var.location
}

output "principal_id" {
  value       = local.output.principal_id
  description = "SQL MI Identity Principal Id"
}

output "resource_group_id" {
  value       = local.parent_id
  description = "Resource group resource id of the SQL Server managed instance."
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
