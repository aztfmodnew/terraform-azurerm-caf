module "diagnostics" {
  source   = "../../diagnostics"
  for_each = try(var.diagnostic_profiles, {})

  resource_id       = azurerm_managed_redis.managed_redis.id
  resource_location = azurerm_managed_redis.managed_redis.location
  diagnostics = coalesce(
    try(var.remote_objects.diagnostics, null),
    try(var.diagnostics, null),
    {}
  )
  profiles          = var.diagnostic_profiles
}
