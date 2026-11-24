module "diagnostics" {
  source            = "../../diagnostics"
  for_each          = try(var.settings.diagnostic_profiles, {})
  resource_id       = azurerm_cosmosdb_account.cosmos_account.id
  resource_location = azurerm_cosmosdb_account.cosmos_account.location
  diagnostics       = var.diagnostics
  profiles          = { (each.key) = each.value }
}
