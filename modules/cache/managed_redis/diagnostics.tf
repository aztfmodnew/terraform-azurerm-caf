module "diagnostics" {
  source   = "../../diagnostics"
  for_each = try(var.diagnostic_profiles, {})

  resource_id       = azurerm_managed_redis.managed_redis.id
  resource_location = azurerm_managed_redis.managed_redis.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = var.diagnostic_profiles
}
