output "palo_alto_virtual_network_appliance_id" {
  description = "The identifier of the created Palo Alto Virtual Network Appliance."
  value       = length(azurerm_palo_alto_virtual_network_appliance.palo_alto_virtual_network_appliance) > 0 ? azurerm_palo_alto_virtual_network_appliance.palo_alto_virtual_network_appliance[0].id : null
}



output "palo_alto_next_generation_firewall_virtual_network_local_rulestack" {
  description = "The ID of the Palo Alto Next Generation Firewall (Virtual Network Local Rulestack)."
  value       = length(azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.palo_alto_ngfw_vnet_local_rulestack) > 0 ? azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.palo_alto_ngfw_vnet_local_rulestack[0].id : null
}

output "palo_alto_next_generation_firewall_virtual_network_panorama_id" {
  description = "The ID of the Palo Alto Next Generation Firewall (Virtual Network Panorama)."
  value       = length(azurerm_palo_alto_next_generation_firewall_virtual_network_panorama.palo_alto_ngfw_vnet_panorama) > 0 ? azurerm_palo_alto_next_generation_firewall_virtual_network_panorama.palo_alto_ngfw_vnet_panorama[0].id : null
}

output "local_rulestack_id" {
  description = "The ID of the associated Local Rulestack created and managed by the sub-module."
  value       = module.local_rulestack.id
}

output "local_rulestack_name" {
  description = "The name of the associated Local Rulestack."
  value       = module.local_rulestack.name
}

# You can expose more outputs from the sub-module if needed
output "local_rulestack_rules" {
  description = "Details of the rules created in the local rulestack."
  value       = module.local_rulestack.rules_output # Assuming sub-module has an output like this
}
