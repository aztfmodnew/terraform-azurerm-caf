module "diagnostics" {
  source = "../../diagnostics"
  count  = lookup(var.settings, "diagnostic_profiles", null) == null ? 0 : 1

  resource_id       = azurerm_linux_web_app.linux_web_app.id
  resource_location = azurerm_linux_web_app.linux_web_app.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = var.settings.diagnostic_profiles
}
