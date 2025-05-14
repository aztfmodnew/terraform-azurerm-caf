output "id" {
  description = "The ID of the Palo Alto Next Generation Firewall (Virtual Network Local Rulestack)."
  value       = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.palo_alto_ngfw_vnet_local_rulestack.id
}

output "name" {
  description = "The name of the Palo Alto Next Generation Firewall."
  value       = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.palo_alto_ngfw_vnet_local_rulestack.name
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
