output "id" {
  description = "The Public IP Prefix ID."
  value       = azurerm_public_ip_prefix.pip_prefix.id

}

output "ip_prefix" {
  description = "The IP address prefix that was allocated."
  value       = azurerm_public_ip_prefix.pip_prefix.ip_prefix

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
