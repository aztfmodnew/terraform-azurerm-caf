module "diagnostics" {
  source = "../../diagnostics"
  count  = try(var.settings.diagnostic_profiles, null) == null ? 0 : 1

  resource_id       = azurerm_bot_service_azure_bot.bot_service.id
  resource_location = local.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
