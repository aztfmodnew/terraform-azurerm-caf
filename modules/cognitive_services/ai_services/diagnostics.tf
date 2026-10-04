module "diagnostics" {
  source = "../../diagnostics"
  count  = lookup(var.settings, "diagnostic_profiles", null) == null ? 0 : 1

  resource_id       = azurerm_cognitive_account.ai_services.id
  resource_location = azurerm_cognitive_account.ai_services.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = var.settings.diagnostic_profiles
}
