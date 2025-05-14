module "diagnostics" {
  source = "../../diagnostics" # Assuming diagnostics module is two levels up
  count  = lookup(var.settings, "diagnostic_profiles", null) == null ? 0 : 1

  resource_id       = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.palo_alto_ngfw_vnet_local_rulestack.id
  #resource_location = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.palo_alto_ngfw_vnet_local_rulestack.location
  resource_location = local.location # Use the location from the locals block
  diagnostics       = try(var.remote_objects.diagnostics, null) # Get diagnostics settings from remote_objects
  profiles          = var.settings.diagnostic_profiles
}
