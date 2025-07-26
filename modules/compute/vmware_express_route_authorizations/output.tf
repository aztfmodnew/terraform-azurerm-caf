output "id" {
  value       = azurerm_vmware_express_route_authorization.vwera.id
  description = "The ID of the VMware Private CLoud."
}
output "express_route_authorization_id" {
  value       = azurerm_vmware_express_route_authorization.vwera.express_route_authorization_id
  description = "The ID of the Express Route Circuit Authorization."
}
output "express_route_authorization_key" {
  value       = azurerm_vmware_express_route_authorization.vwera.express_route_authorization_key
  description = "The key of the Express Route Circuit Authorization."
}
# output "express_route_authorization_id" {
#   value       = azurerm_vmware_private_cloud.vwera.express_route_authorization_id
#   description = "The ID of the Express Route Circuit Authorization."
# }
# output "express_route_authorization_key" {
#   value       = azurerm_vmware_private_cloud.vwera.express_route_authorization_key
#   description = "The key of the Express Route Circuit Authorization."
# }
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
