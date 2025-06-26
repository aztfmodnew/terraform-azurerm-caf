module "diagnostics" {
  source = "../../../diagnostics"
  count  = lookup(var.settings, "diagnostic_profiles", null) == null ? 0 : 1

  resource_id       = azurerm_cdn_frontdoor_endpoint.endpoint.id
  resource_location = azurerm_cdn_frontdoor_endpoint.endpoint.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = var.settings.diagnostic_profiles
}
