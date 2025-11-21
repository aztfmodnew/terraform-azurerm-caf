module "diagnostics" {
  source = "../../diagnostics"
  count  = length(try(var.diagnostic_profiles, {})) > 0 ? 1 : 0

  resource_id       = azurerm_route_server.route_server.id
  resource_location = local.location
  diagnostics       = var.diagnostics
  profiles          = var.diagnostic_profiles
}
