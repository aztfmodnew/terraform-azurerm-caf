output "id" {
  value = azurerm_private_dns_zone.private_dns.id
}

output "name" {
  value = azurerm_private_dns_zone.private_dns.name
}

output "resource_group_name" {
  value = local.resource_group_name
}

output "base_tags" {
  value = local.tags
}

output "a" {
  value = azurerm_private_dns_a_record.a_records
}

output "aaaa" {
  value = azurerm_private_dns_aaaa_record.aaaa_records
}

output "cname" {
  value = azurerm_private_dns_cname_record.cname_records
}

output "mx" {
  value = azurerm_private_dns_mx_record.mx_records
}

output "ptr" {
  value = azurerm_private_dns_ptr_record.ptr_records
}

output "srv" {
  value = azurerm_private_dns_srv_record.srv_records
}

output "txt" {
  value = azurerm_private_dns_txt_record.txt_records
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
