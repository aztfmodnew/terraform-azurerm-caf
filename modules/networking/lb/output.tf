output "id" {
  value       = azurerm_lb.lb.id
  description = "The Load Balancer ID."
}
output "frontend_ip_configuration" {
  value       = azurerm_lb.lb.frontend_ip_configuration
  description = "A `frontend_ip_configuration` block as documented below."
}
output "private_ip_address" {
  value       = azurerm_lb.lb.private_ip_address
  description = "The first private IP address assigned to the load balancer in `frontend_ip_configuration` blocks, if any."
}
output "private_ip_addresses" {
  value       = azurerm_lb.lb.private_ip_addresses
  description = "The list of private IP address assigned to the load balancer in `frontend_ip_configuration` blocks, if any."
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
