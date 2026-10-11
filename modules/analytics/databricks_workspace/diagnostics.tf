module "diagnostics" {
  source = "../../diagnostics"

  resource_id       = azurerm_databricks_workspace.ws.id
  resource_location = local.location
  diagnostics       = var.diagnostics
  profiles          = coalesce(try(var.settings.diagnostic_profiles, null), {})
}