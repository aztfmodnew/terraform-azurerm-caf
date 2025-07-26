output "id" {
  value       = azurerm_lb_backend_address_pool.lb.id
  description = "The ID of the Backend Address Pool."
}
output "backend_ip_configurations" {
  value       = azurerm_lb_backend_address_pool.lb.backend_ip_configurations
  description = "The Backend IP Configurations associated with this Backend Address Pool."
}
output "load_balancing_rules" {
  value       = azurerm_lb_backend_address_pool.lb.load_balancing_rules
  description = "The Load Balancing Rules associated with this Backend Address Pool."
}
output "outbound_rules" {
  value       = azurerm_lb_backend_address_pool.lb.outbound_rules
  description = "An array of the Load Balancing Outbound Rules associated with this Backend Address Pool."
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
