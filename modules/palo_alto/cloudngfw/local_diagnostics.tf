locals {
  actual_ngfw_resource_id = var.settings.attachment_type == "vnet" ? (
    var.settings.management_mode == "rulestack" ?
    try(azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.palo_alto_ngfw_vnet_local_rulestack[0].id, null) :
    try(azurerm_palo_alto_next_generation_firewall_virtual_network_panorama.palo_alto_ngfw_vnet_panorama[0].id, null)
  ) : try(azurerm_palo_alto_virtual_network_appliance.palo_alto_virtual_network_appliance[0].id, null)

  diagnostics_enabled_for_ngfw = local.actual_ngfw_resource_id != null && lookup(var.settings, "diagnostic_profiles", null) != null
} 