module "diagnostics" {
  source = "../../diagnostics"                                               # Assuming diagnostics module is three levels up from here
  count  = lookup(var.settings, "diagnostic_profiles", null) == null ? 0 : 1 # Check if diagnostic_profiles are defined for the rulestack

  resource_id       = azurerm_palo_alto_local_rulestack.local_rulestack.id
  resource_location = azurerm_palo_alto_local_rulestack.local_rulestack.location
  diagnostics       = try(var.remote_objects.diagnostics, null)
  profiles          = var.settings.diagnostic_profiles
}
