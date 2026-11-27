module "diagnostics" {
  source            = "../../diagnostics"
  for_each          = try(var.settings.diagnostic_profiles, {})
  resource_id       = azurerm_logic_app_standard.logic_app_standard.id
  resource_location = azurerm_logic_app_standard.logic_app_standard.location
  diagnostics       = var.diagnostics
  profiles          = { (each.key) = each.value }
}
