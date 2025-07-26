output "dns_domain_registration_name" {
  description = "DNS domain name purchased"
  value       = local.dns_domain_name
}

output "dns_domain_registration_id" {
  description = "DNS domain name resource ID"
  value       = jsondecode(azurerm_resource_group_template_deployment.domain.output_content).id.value
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
