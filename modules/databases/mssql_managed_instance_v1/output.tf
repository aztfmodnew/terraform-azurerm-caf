output "id" {
  value       = azurerm_mssql_managed_instance.mssqlmi.id
  description = "SQL Managed instance Id"
}
output "fqdn" {
  value       = azurerm_mssql_managed_instance.mssqlmi.fqdn
  description = "The fully qualified domain name of the Azure Managed SQL Instance"
}
output "name" {
  value       = data.azurecaf_name.mssqlmi.result
  description = "SQL MI Name"
}
output "location" {
  value = local.location
}
output "principal_id" {
  value       = can(var.settings.identity) ? azurerm_mssql_managed_instance.mssqlmi.identity.0.principal_id : null
  description = "SQL Managed Instance Principal Id"
}
output "identity" {
  value       = can(var.settings.identity) ? azurerm_mssql_managed_instance.mssqlmi.identity : null
  description = "SQL Managed Instance identities"
}
output "dns_zone_id" {
  value       = local.dns_zone_id
  description = "this is the zone id extracted from sql managed instance server fqdn and can be used while creating private dns zone for the managed instance"
}
output "resource_group_id" {
  value       = local.resource_group_id
  description = "Resource group id of the sql mi server."
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
